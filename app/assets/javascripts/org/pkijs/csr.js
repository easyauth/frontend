function demo_perform() {
  var fields = ["cn", "email", "o", "ou", "l", "c"];
  fields.forEach(
      function(elem) {elem = "csrgen_x509_" + elem;
      document.getElementById(elem).value = document.getElementById(elem).placeholder;}
      );
  }
  function formatPEM(pem_string)
  {
  var string_length = pem_string.length;
  var result_string = "";

  for(var i = 0, count = 0; i < string_length; i++, count++)
  {
    if(count > 63)
    {
      result_string = result_string + "\r\n";
      count = 0;
    }

    result_string = result_string + pem_string[i];
  }

  return result_string;
  }
  function arrayBufferToString(buffer)
  {
  var result_string = "";
  var view = new Uint8Array(buffer);

  for(var i = 0; i < view.length; i++)
    result_string = result_string + String.fromCharCode(view[i]);

  return result_string;
  }
  //*********************************************************************************
  // #region Create PKCS#10 
  //*********************************************************************************
  function create_new_csr()
  {
  document.getElementById("csrgen_btn").disabled = true;
  // #region Initial variables 


  var sequence = Promise.resolve();

  var pkcs10_simpl = new org.pkijs.simpl.PKCS10();

  var publicKey;
  var privateKey;

  var hash_algorithm;
  //var hash_option = document.getElementById("hash_alg").value;
  var hash_option = 'alg_SHA256';
  switch(hash_option)
  {
    case "alg_SHA1":
      hash_algorithm = "sha-1";
      break;
    case "alg_SHA256":
      hash_algorithm = "sha-256";
      break;
    case "alg_SHA384":
      hash_algorithm = "sha-384";
      break;
    case "alg_SHA512":
      hash_algorithm = "sha-512";
      break;
    default:;
  }

  var signature_algorithm_name;
  //var sign_option = document.getElementById("sign_alg").value;
  var sign_option = 'alg_RSA15';
  switch(sign_option)
  {
    case "alg_RSA15":
      signature_algorithm_name = "RSASSA-PKCS1-V1_5";
      break;
    case "alg_RSA2":
      signature_algorithm_name = "RSA-PSS";
      break;
    case "alg_ECDSA":
      signature_algorithm_name = "ECDSA";
      break;
    default:;
  }
  // #endregion 

  // #region Get a "crypto" extension 
  var crypto = org.pkijs.getCrypto();
  if(typeof crypto == "undefined")
  {
    alert("No WebCrypto extension found - please use a better browser!");
    return;
  }
  // #endregion 

  // #region Put CSR metadata
  pkcs10_simpl.version = 0;
  //2.5.4.7 - C
  pkcs10_simpl.subject.types_and_values.push(new org.pkijs.simpl.ATTR_TYPE_AND_VALUE({ type: "2.5.4.6", value: new org.pkijs.asn1.PRINTABLESTRING({ value: "Canada" }) }));
  //2.5.4.7 - L
  pkcs10_simpl.subject.types_and_values.push(new org.pkijs.simpl.ATTR_TYPE_AND_VALUE({ type: "2.5.4.7", value: new org.pkijs.asn1.UTF8STRING({ value: "Oakville" }) }));
  //2.5.4.10 - O
  pkcs10_simpl.subject.types_and_values.push(new org.pkijs.simpl.ATTR_TYPE_AND_VALUE({ type: "2.5.4.10", value: new org.pkijs.asn1.UTF8STRING({ value: "Easyauth" }) }));
  //2.5.4.11 - OU
  pkcs10_simpl.subject.types_and_values.push(new org.pkijs.simpl.ATTR_TYPE_AND_VALUE({ type: "2.5.4.11", value: new org.pkijs.asn1.UTF8STRING({ value: "User Certificates" }) }));
  //2.5.4.3 - commonName
  pkcs10_simpl.subject.types_and_values.push(new org.pkijs.simpl.ATTR_TYPE_AND_VALUE({ type: "2.5.4.3", value: new org.pkijs.asn1.UTF8STRING({ value: "Easyauth User" }) }));
  // 2.5.29.17 - SAN // 1.2.840.113549.1.9.1 - emailAddress
  pkcs10_simpl.subject.types_and_values.push(new org.pkijs.simpl.ATTR_TYPE_AND_VALUE({ type: "2.5.29.17", value: new org.pkijs.asn1.IA5STRING({ value: "email:" + "noreply@easyauth.org" }) }));

  pkcs10_simpl.attributes = new Array();
  // #endregion 

  // #region Create a new key pair 
  sequence = sequence.then(
      function()
      {
      // #region Get default algorithm parameters for key generation 
      var algorithm = org.pkijs.getAlgorithmParameters(signature_algorithm_name, "generatekey");
      if("hash" in algorithm.algorithm)
      algorithm.algorithm.hash.name = hash_algorithm;
      // #endregion 

      return crypto.generateKey(algorithm.algorithm, true, algorithm.usages);
      }
      );
  // #endregion 

  // #region Store new keypair in interim variables
  sequence = sequence.then(
      function(keyPair)
      {
      publicKey = keyPair.publicKey;
      privateKey = keyPair.privateKey;
      },
      function(error)
      {
      alert("Error during key generation: " + error);
      }
      );
  // #endregion 

  // #region Exporting public key into "subjectPublicKeyInfo" value of PKCS#10 
  sequence = sequence.then(
      function()
      {
      return pkcs10_simpl.subjectPublicKeyInfo.importKey(publicKey);
      }
      );
  // #endregion 

  // #region SubjectKeyIdentifier 
  sequence = sequence.then(
      function(result)
      {
      return crypto.digest({ name: "SHA-256" }, pkcs10_simpl.subjectPublicKeyInfo.subjectPublicKey.value_block.value_hex);
      }
      ).then(
        function(result)
        {
        if (true) { return result; }
        pkcs10_simpl.attributes.push(new org.pkijs.simpl.ATTRIBUTE({
  type: "1.2.840.113549.1.9.14", // pkcs-9-at-extensionRequest
  values: [(new org.pkijs.simpl.EXTENSIONS({
  extensions_array: [
  new org.pkijs.simpl.EXTENSION({
  extnID: "2.5.29.14",
  critical: false,
  extnValue: (new org.pkijs.asn1.OCTETSTRING({ value_hex: result })).toBER(false)
  })
  ]
  })).toSchema()]
  }));
  }
  );
  // #endregion 

  // #region Signing final PKCS#10 request 
  sequence = sequence.then(
      function()
      {
      return pkcs10_simpl.sign(privateKey, hash_algorithm);
      },
      function(error)
      {
      alert("Error during exporting public key: " + error);
      }
      );
  // #endregion 

  sequence = sequence.then(
      function(result)
      {
      var pkcs10_schema = pkcs10_simpl.toSchema();
      var pkcs10_encoded = pkcs10_schema.toBER(false);

      var result_string = "-----BEGIN CERTIFICATE REQUEST-----\r\n";
      result_string = result_string + formatPEM(window.btoa(arrayBufferToString(pkcs10_encoded)));
      result_string = result_string + "\r\n-----END CERTIFICATE REQUEST-----\r\n";

      var pemUrl = "" 
      var pemUrl = "data:application/octet-stream;charset=UTF-8;base64," + btoa(result_string);



       document.getElementById("pem_certificate").textContent = result_string;
       //document.getElementById("certificate-download").setAttribute("href", pemUrl);




     
      },
      function(error)
      {
      alert("Error signing PKCS#10: " + error);
      }
      );

  sequence = sequence.then(
      function()
      {
      return crypto.exportKey("pkcs8", privateKey);
      }
      );
  // #endregion 

  sequence.then(
      function(result)
      {
      var private_key_string = String.fromCharCode.apply(null, new Uint8Array(result));

      var result_string = '';
        
      result_string = result_string + "-----BEGIN PRIVATE KEY-----\r\n";
      result_string = result_string + formatPEM(window.btoa(private_key_string));
      result_string = result_string + "\r\n-----END PRIVATE KEY-----\r\n";
      var pemUrl = "data:application/octet-stream;charset=UTF-8;base64," + btoa(result_string);

       document.getElementById("private-key-download").setAttribute("href", pemUrl);
       $("#private-key-download").click()

      document.getElementById("csrgen_btn").disabled = false;
      },
      function(error)
      {
      alert("Error during exporting of private key: " + error);
      }
      );
    return false;
  }
  //*********************************************************************************
  // #endregion 
  //*********************************************************************************

