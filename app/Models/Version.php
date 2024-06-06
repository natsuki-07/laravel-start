<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use BaoPham\DynamoDb\DynamoDbModel;

class Version extends DynamoDbModel
{
    use HasFactory;

    //DynamoDBで設定したテーブル名
    protected $table = 'demo-db';
}
