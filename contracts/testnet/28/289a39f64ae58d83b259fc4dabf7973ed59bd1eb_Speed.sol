// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Burnable.sol";
import "./Ownable.sol";
import "./Counters.sol";

contract Speed is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Speed", "SPE") {}

    struct Car{
        address owner;
        uint token;         //nftid
        uint carType;     //车型
        uint engine;        //动力系统
        uint os;            //操作系统
        uint driverOS;      //驾驶系统
        string modelUri;    //模型uri
        uint[] technology;    //科技配置
        uint[] extereior;   //外观
    }

    // struct Exterior{
    //     uint carColor;
    //     uint hubColor;
    //     uint hubSize;
    //     uint hubType;
    //     uint tailType;
    //     uint tailColor;
    //     uint doorColor;
    //     uint carTopColor;
    //     uint reflector;
    //     uint lightColor;
    //     uint carBodyType;
    //     uint tailLight;

    // }

    mapping(address=>Car[])  ownerCars;
    Car[] cars;

    function _baseURI() internal pure override returns (string memory) {
        return "https://speedfi.oss-cn-shenzhen.aliyuncs.com/";
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    event CreateCarLog(address,uint256);
// address _to 给谁的车
// string memory _uri json的名字
// uint _engine 引擎
// uint[] calldata _technology 科技
// uint[] calldata _exterior 外观
// uint _os 车系统
// uint _driverOs 驾驶系统
    function CreateCar(address _to,string memory _uri,uint _carType,uint _engine,uint[] calldata _technology,uint[] calldata _exterior,uint _os,uint _driverOs,string memory _modelUri)  public onlyOwner returns (uint256){
        Car memory c;
        c.carType = _carType;
        c.engine = _engine;
        c.os = _os;
        c.driverOS = _driverOs;
        c.technology = _technology;
        c.extereior = _exterior;
        // require(!checkCar(c),"Exists same car!");
        _tokenIdCounter.increment();
        uint256 _tokenId = _tokenIdCounter.current();
        c.token = _tokenId;
        c.owner = _to;
        c.modelUri = _modelUri;
        ownerCars[_to].push(c);
        cars.push(c);
        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, _uri);
        emit CreateCarLog(_to,_tokenId);
        return (_tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // function checkCar(Car memory car) public view returns (bool){
    //     bool isSame = false;
    //     for (uint i=0;i<cars.length;i++){
    //         Car memory tmpCar = cars[i];
    //         if (tmpCar.engine != car.engine){
    //             continue;
    //         }
    //         if (tmpCar.os != car.os){
    //             continue;
    //         }
    //         bool isTec = true;
    //         if (tmpCar.technology.length != car.technology.length){
    //             continue;
    //         }
    //         for(uint j=0;j<tmpCar.technology.length;j++){
    //             if(car.technology[j] !=  tmpCar.technology[j]){
    //                 isTec = false;
    //                 break;
    //             }
    //         }
    //         if (!isTec){
    //             continue;
    //         }
    //         bool isExt = true;
    //         if (tmpCar.extereior.length != car.extereior.length){
    //             continue;
    //         }
    //         for(uint j=0;j<tmpCar.extereior.length;j++){
    //             if(car.extereior[j] !=  tmpCar.extereior[j]){
    //                 isExt = false;
    //                 break;
    //             }
    //         }
    //          if (!isExt){
    //             continue;
    //         }

    //         isSame = true;
    //         return isSame;
            
    //     }
    //     return isSame;
    // }

    function getByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](balanceOf(_owner));
        uint counter = 0;
        for (uint i = 1; i <= _tokenIdCounter.current(); i++) {
            if (ownerOf(i) == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function getCar(address _owener,uint nftId ) external view returns (uint256 token ,uint256 carType,uint256 engine,uint256 os,uint256 driverOS,string memory uri,string memory modelUri ,uint[] memory  technology,uint[] memory extereior){
        Car[] memory  cs = ownerCars[_owener];
        require(cs.length > 0, "Did not own cars");
        uri = tokenURI(nftId);
        for (uint i=0;i<cs.length;i++){
            Car memory tmpCar = cars[i];
            if (tmpCar.token == nftId){    
                 string memory base = _baseURI();
                 tmpCar.modelUri = string(abi.encodePacked(base, tmpCar.modelUri));
                return (tmpCar.token,tmpCar.carType,tmpCar.engine,tmpCar.os,tmpCar.driverOS,uri,tmpCar.modelUri,tmpCar.technology,tmpCar.extereior);
            }
        }
        revert("Did not own cars!");
    }
   
}