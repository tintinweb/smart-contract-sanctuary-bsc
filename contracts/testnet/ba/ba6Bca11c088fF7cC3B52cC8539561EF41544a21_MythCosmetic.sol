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

    function changeBackgroundUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(0, _id, _url);
        backgroundExists[_id] = true;
        backgroundURL[_id] = _url;
    }

    function changeEyeUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(1, _id, _url);
        eyeExists[_id] = true;
        eyeURL[_id] = _url;
    }

    function changeMouthUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(2, _id, _url);
        mouthExists[_id] = true;
        mouthURL[_id] = _url;
    }

    function changeNoseUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(3, _id, _url);
        noseExists[_id] = true;
        noseURL[_id] = _url;
    }

    function changeSkinColorUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(4, _id, _url);
        skinColorExists[_id] = true;
        skinColorURL[_id] = _url;
    }

    function changeBodyUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(5, _id, _url);
        bodyExists[_id] = true;
        bodyURL[_id] = _url;
    }

    function changeHeadUrl(string calldata _url, uint256 _id)
        external
        onlyOwner
    {
        emit cosmeticAdded(6, _id, _url);
        headExists[_id] = true;
        headURL[_id] = _url;
    }
}