onRecordAfterCreateRequest((e) => {
    const guest = e.record;
    const email = guest.get('email');
    const name = guest.get('first_name') + ' ' + (guest.get('last_name') || '');

    if (!email) return;

    try {
        const qrCode = guest.get('qr_code');
        const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${qrCode}`;

        const message = new MailerMessage({
            from: {
                address: $app.settings().meta.senderAddress,
                name:    $app.settings().meta.senderName,
            },
            to:      [{address: email}],
            subject: "Willkommen am TEKO Stand!",
            html:    `
                <div style="font-family: Arial, sans-serif; color: #333;">
                    <h2 style="color: #00A9AC;">Hallo ${name},</h2>
                    <p>
                        Vielen Dank für deine Registrierung an unserem Messestand!
                    </p>
                    <div style="margin: 20px 0;">
                        <img src="${qrUrl}" alt="QR Code" style="border: 2px solid #ccc; padding: 10px; border-radius: 10px;" />
                    </div>
                    <p>Viele Grüße,<br>Das TEKO Team</p>
                </div>
            `,
        });

        $app.newMailClient().send(message);
    } catch (err) {
        $app.logger().error("Guest Email Error", err);
    }
}, 'guests');
