import sendgrid
import os
from sendgrid.helpers.mail import Mail, Email, To, Content

def sendgridmail(user,TEXT):
    sg = sendgrid.SendGridAPIClient('Api_key')
    from_email = Email("noelcoc003@gmail.com")  # Change to your verified sender
    to_email = To(user)  # Change to your recipient
    subject = "Containmentzone Alert"
    content = Content("text/plain",TEXT)
    mail = Mail(from_email, to_email, subject, content)

    # Get a JSON-ready representation of the Mail object
    mail_json = mail.get()
    # Send an HTTP POST request to /mail/send
    response = sg.client.mail.send.post(request_body=mail_json)
    print(response.status_code)
    print(response.headers)
