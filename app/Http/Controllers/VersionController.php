<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\Version;

class VersionController extends Controller
{
    public function index()
    {
        $result = Version::first();
        return $result;
    }
}
