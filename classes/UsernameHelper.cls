public class UsernameHelper {
    public static String Generate() {
        return String.format('{0}@cventcustomer.com', new String[] {
            					EncodingUtil.convertToHex(Crypto.generateDigest('MD5',
            					Blob.valueOf(DateTime.now().getTime().format()))) 
            				});
    }
}