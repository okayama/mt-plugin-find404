package Find404::L10N::ja;
use strict;
use base qw( Find404::L10N MT::L10N MT::Plugin::L10N );
use vars qw( %Lexicon );

our %Lexicon = (
    'Available Find404.' => '404 になったらメールします。',
    'Check URL' => 'チェック対象 URL',
    'Settings for URL' => 'URL に関する設定',
    'Settings for mail' => 'メールに関する設定',
    'Mail subject' => '件名',
    'Mail body' => '本文',
    'Mail from' => '送信元',
    'Mail to' => '送信先',
    'Separated by comma' => 'カンマ区切り',
    'One setting per line' => '一行ずつ',
    '[_1] exists.' => '[_1] は存在します。',
    '[_1] unexists.' => '[_1] は存在しません。',
    'Find404 Task' => 'Find404 のタスク',
);

1;
