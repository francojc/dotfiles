
{ pkgs, ... }:

{
  programs.wofi = {
    enable = true;
    style = ''
      window {
        margin: 50px;
        border: 1px solid #458588;
        border-radius: 10px;
      }

      #input {
        margin: 5px;
        border: none;
        color: #ebdbb2;
        background-color: #3c3836;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: #3c3836;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: #3c3836;
      }

      #scroll {
        margin: 5px;
        border: none;
        background-color: #3c3836;
      }

      #text {
        margin: 5px;
        border: none;
        color: #ebdbb2;
      }

      #entry:selected {
        background-color: #458588;
      }
    '';
  };
}
