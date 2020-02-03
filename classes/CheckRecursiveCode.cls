public class CheckRecursiveCode{
private static boolean runThird = true;
public static boolean runOnceThird(){
        if(runThird){
            runThird = false;
            return true;
        }else{
            return runThird ;
        }
    }
}