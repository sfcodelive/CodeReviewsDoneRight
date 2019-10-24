class SimplyBadCode {
  public static void loopExample(){
    for(Integer i = 0; i <500; i++){
      Contact c = new Contact(name='name '+i);
      insert c;
    }
  }
}