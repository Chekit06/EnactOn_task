# EnactOn_task

**I have Explained the script line by line using the comments in the script as well as in the video provided in the Email as asked.**

# Backup and Rotation
Steps Followed from rclone documentation

- Brew install rclone (Installing rclone using brew for mac setup)
- running rclone config to configure the gdrive api using client ID and secret (Later created in google admin account)

<img width="1582" alt="Screenshot 2025-02-03 at 9 50 29 PM" src="https://github.com/user-attachments/assets/bb1911cd-5662-4c95-ad4c-725d00229ed6" />

<img width="777" alt="Screenshot 2025-02-03 at 9 59 38 PM" src="https://github.com/user-attachments/assets/aa49fa11-d1bf-4c3f-a613-22a44421811f" />

  
- In the google admin page, Created a project first and enabled the gdrive API in that project

<img width="649" alt="Screenshot 2025-02-03 at 5 17 38 PM" src="https://github.com/user-attachments/assets/4844712e-6934-4f6b-ad91-829ee321b35c" />

<img width="1444" alt="Screenshot 2025-02-03 at 5 19 00 PM" src="https://github.com/user-attachments/assets/84c92b34-e098-4e6a-ac28-97185ba60330" />

<img width="1470" alt="Screenshot 2025-02-03 at 5 27 50 PM" src="https://github.com/user-attachments/assets/e1345024-dc6e-4f0b-8d98-b9b5b367a989" />

- Then configured consent screen and added scopes for rclone to access and modify gdrive files.
- Create new client & secret to authenticate rclone gdrive using oauth client ID

- Publish APP for testing and also added a test user (own google account)
- Update the client id and secret to rclone


# Discord Integration for CURL

- Created a server and create a web hook 
- Used this web hook url in the script with curl
  
<img width="1582" alt="Screenshot 2025-02-03 at 9 45 45 PM" src="https://github.com/user-attachments/assets/d4751f1a-b69c-4b9d-84a5-870582b066d1" />

<img width="1582" alt="Screenshot 2025-02-03 at 9 44 45 PM" src="https://github.com/user-attachments/assets/0e8fc796-8084-4e96-9de7-8266203bd123" />

- As you can see we are getting alerts for backup completion for both weekly and daily as i have if condition setup for monday for weekly backups.

**I have Explained the script line by line using the comments in the script as well as in the video provided in the Email as asked**
