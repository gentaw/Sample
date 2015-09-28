Configuration IISConfiguration
{
  Node localhost
  {
     WindowsFeature IIS
      {
        Ensure = "Present"
        Name = "Web-Server"
      }

    WindowsFeature AspNet45
    {
      Ensure = "Present"
      Name = "Web-Asp-Net45"
    }
  }
}

IISConfiguration -OutputPath .
Start-DscConfiguration .\IISConfiguration
