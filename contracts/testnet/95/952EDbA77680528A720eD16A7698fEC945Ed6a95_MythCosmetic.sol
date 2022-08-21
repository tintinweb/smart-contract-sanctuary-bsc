// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract MythCosmetic {
    address public owner;
    mapping(uint256 => string) public backgroundURL;
    mapping(uint256 => string) public eyeURL;
    mapping(uint256 => string) public mouthURL;
    mapping(uint256 => string) public noseURL;
    mapping(uint256 => string) public skinColorURL;
    mapping(uint256 => string) public bodyURL;
    mapping(uint256 => string) public headURL;

    mapping(uint256 => bool) public backgroundExists;
    mapping(uint256 => bool) public eyeExists;
    mapping(uint256 => bool) public mouthExists;
    mapping(uint256 => bool) public noseExists;
    mapping(uint256 => bool) public skinColorExists;
    mapping(uint256 => bool) public bodyExists;
    mapping(uint256 => bool) public headExists;

    event cosmeticAdded(uint256 layerType, uint256 layerId, string imageURL);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    function removeCosmetic(uint256 _layerType, uint256 _id)
        external
        onlyOwner
    {
        require(_layerType >= 0 && _layerType <= 6, "Layer Type incorrect");
        if (_layerType == 0) {
            delete backgroundURL[_id];
            delete backgroundExists[_id];
        } else if (_layerType == 1) {
            delete eyeURL[_id];
            delete eyeExists[_id];
        } else if (_layerType == 2) {
            delete mouthURL[_id];
            delete mouthExists[_id];
        } else if (_layerType == 3) {
            delete noseURL[_id];
            delete noseExists[_id];
        } else if (_layerType == 4) {
            delete skinColorURL[_id];
            delete skinColorExists[_id];
        } else if (_layerType == 5) {
            delete bodyURL[_id];
            delete bodyExists[_id];
        } else if (_layerType == 6) {
            delete headURL[_id];
            delete headExists[_id];
        }
    }

    function changeBackgroundUrl(string[] calldata _url, uint256[] calldata _id)
        external
        onlyOwner
    {
        require(_url.length == _id.length, "The lists need to be same length");
        for (uint256 i = 0; i < _id.length; i++) {
            emit cosmeticAdded(0, _id[i], _url[i]);
            backgroundExists[_id[i]] = true;
            backgroundURL[_id[i]] = _url[i];
        }
    }

    function changeEyeUrl(string[] calldata _url, uint256[] calldata _id)
        external
        onlyOwner
    {
        require(_url.length == _id.length, "The lists need to be same length");
        for (uint256 i = 0; i < _id.length; i++) {
            emit cosmeticAdded(1, _id[i], _url[i]);
            eyeExists[_id[i]] = true;
            eyeURL[_id[i]] = _url[i];
        }
    }

    function changeMouthUrl(string[] calldata _url, uint256[] calldata _id)
        external
        onlyOwner
    {
        require(_url.length == _id.length, "The lists need to be same length");
        for (uint256 i = 0; i < _id.length; i++) {
            emit cosmeticAdded(2, _id[i], _url[i]);
            mouthExists[_id[i]] = true;
            mouthURL[_id[i]] = _url[i];
        }
    }

    function changeNoseUrl(string[] calldata _url, uint256[] calldata _id)
        external
        onlyOwner
    {
        require(_url.length == _id.length, "The lists need to be same length");
        for (uint256 i = 0; i < _id.length; i++) {
            emit cosmeticAdded(3, _id[i], _url[i]);
            noseExists[_id[i]] = true;
            noseURL[_id[i]] = _url[i];
        }
    }

    function changeSkinColorUrl(string[] calldata _url, uint256[] calldata _id)
        external
        onlyOwner
    {
        require(_url.length == _id.length, "The lists need to be same length");
        for (uint256 i = 0; i < _id.length; i++) {
            emit cosmeticAdded(4, _id[i], _url[i]);
            skinColorExists[_id[i]] = true;
            skinColorURL[_id[i]] = _url[i];
        }
    }

    function changeBodyUrl(string[] calldata _url, uint256[] calldata _id)
        external
        onlyOwner
    {
        require(_url.length == _id.length, "The lists need to be same length");
        for (uint256 i = 0; i < _id.length; i++) {
            emit cosmeticAdded(5, _id[i], _url[i]);
            bodyExists[_id[i]] = true;
            bodyURL[_id[i]] = _url[i];
        }
    }

    function changeHeadUrl(string[] calldata _url, uint256[] calldata _id)
        external
        onlyOwner
    {
        require(_url.length == _id.length, "The lists need to be same length");
        for (uint256 i = 0; i < _id.length; i++) {
            emit cosmeticAdded(6, _id[i], _url[i]);
            headExists[_id[i]] = true;
            headURL[_id[i]] = _url[i];
        }
    }
}