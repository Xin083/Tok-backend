package email

import (
	"douyin-backend/app/global/variable"

	"gopkg.in/gomail.v2"
)

// SendVerificationCode 发送验证码邮件
func SendVerificationCode(to, code string) error {
	m := gomail.NewMessage()
	m.SetHeader("From", variable.ConfigYml.GetString("Email.FromName")+" <"+variable.ConfigYml.GetString("Email.From")+">")
	m.SetHeader("To", to)
	m.SetHeader("Subject", "验证码")
	m.SetBody("text/html", "您的验证码是: <b>"+code+"</b><br>验证码有效期为5分钟，请尽快使用。")

	d := gomail.NewDialer(
		variable.ConfigYml.GetString("Email.Host"),
		variable.ConfigYml.GetInt("Email.Port"),
		variable.ConfigYml.GetString("Email.Username"),
		variable.ConfigYml.GetString("Email.Password"),
	)

	return d.DialAndSend(m)
}
