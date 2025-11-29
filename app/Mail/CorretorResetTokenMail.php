<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class CorretorResetTokenMail extends Mailable
{
    use Queueable, SerializesModels;

    public string $nome;
    public string $token;

    public function __construct(string $nome, string $token)
    {
        $this->nome  = $nome;
        $this->token = $token;
    }

    public function build()
    {
        return $this->from(config('mail.from.address'), config('mail.from.name'))
                    ->subject('Token de redefinição de senha')
                    ->view('emails.corretores.reset-token')
                    ->with(['nome' => $this->nome, 'token' => $this->token]);
    }
}
