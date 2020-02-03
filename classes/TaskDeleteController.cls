public class TaskDeleteController {

     

      Task task;

      public Boolean isOwner  {get;set;}

     

      public TaskDeleteController(ApexPages.StandardController std){

            task = new Task();

            isOwner = false;

            task = [Select Id, OwnerId From Task Where Id = :std.getId()];

            if(task.OwnerId == UserInfo.getUserId())

                  isOwner = true;

            else

                  isOwner = false;

      }

}