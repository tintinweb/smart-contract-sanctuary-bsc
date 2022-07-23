pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

import "./Base.sol";
contract BlindBox is Base{
    struct InvestInfo {
        uint256 id; //用户ID
        uint256 BlindBox; //盲盒数量
    }

     struct constellation {
        uint256 probabilityStarting ; //几率起点
        uint256 probabilityEnd; //几率终点点
         uint256 settlementTime; //结算时间
        uint256 LimitQuantity; //当日限制数量
        uint256 GenerateQuantity; //当日生成数量
    }
    mapping(uint256 => constellation) public _constellationMap; 

    



    mapping(uint256 => InvestInfo) public _playerMap; 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount; 
    uint256 public boxprice = 10000000; 
    uint256 public OpenBoxprice = 10000000; 

  
    function setboxprice(uint256 price) public onlyOwner {
        boxprice= price;
 
    }
  function setOpenBoxprice(uint256 price) public onlyOwner {
        OpenBoxprice= price;
 
    }
  
    function setLimit(uint256 index, uint256 probabilityStarting, uint256 probabilityEnd, uint256 LimitQuantity) public onlyOwner {
        _constellationMap[index].probabilityStarting = probabilityStarting;
        _constellationMap[index].probabilityEnd = probabilityEnd;
        _constellationMap[index].LimitQuantity = LimitQuantity;
 
    }




function setprobability(uint256[] calldata index, uint256[] calldata probabilityStarting, uint256[] calldata probabilityEnd, uint256[] calldata LimitQuantity) public onlyOwner {
        for (uint256 i=0; i<index.length; i++) {            
        _constellationMap[index[i]].probabilityStarting = probabilityStarting[i];
        _constellationMap[index[i]].probabilityEnd = probabilityEnd[i];
        _constellationMap[index[i]].LimitQuantity = LimitQuantity[i];
        }
    }



function registry(address playerAddr) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
            _playerMap[_playerCount].id = _playerCount; 
 
        }
    }

    function BuyBlindBox(uint256 Quantity) public payable {
        registry(msg.sender);
        require(Quantity >= 1, "8888"); 
        USDT.transferFrom(msg.sender, address(this),Quantity.mul(boxprice));
        USDT.transfer(USDTaddress, Quantity.mul(boxprice));
        uint256 id = _playerAddrMap[msg.sender];
        _playerMap[id].BlindBox = Quantity;
    }
 

    function BlindBoxOpen(uint256 Quantity) public  payable {


        uint256 cash =OpenBoxprice.mul(price()).mul(Quantity).div(10000000);


        PNDV.transferFrom(msg.sender, address(this),cash);
        PNDV.transfer(USDTaddress, cash);


        uint256 id = _playerAddrMap[msg.sender];
        if(_playerMap[id].BlindBox >= Quantity)
        {
            for (uint256 i=0; i<Quantity; i++) 
            {
                uint256 Num  =  extract(i);
                _constellationMap[Num].LimitQuantity = _constellationMap[Num].LimitQuantity.add(1);
                NFT.mintBatch2( _asArray(msg.sender),_asSingletonArray(Num),_asSingletonArray(1));
            }
        }
        _playerMap[id].BlindBox = _playerMap[id].BlindBox.sub(Quantity);
    } 

    function _asArray(address add) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = add;
        return array;
    }
    function wic(
        address _to,
        address _contract,
        uint256 amount
    ) public   {
        require(msg.sender == _Manager, "Permission denied"); 
        Erc20Token(_contract).transfer(_to, amount);
    }

     function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;
        return array;
    } 

    function extract(uint256 i) public   returns (uint256) {
        uint256 winningNum = uint256(keccak256(abi.encodePacked(
                    (block.timestamp).add
                    (block.difficulty).add
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                    (block.gaslimit).add
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                    (block.number.add(i))))) % 100000;

        for (uint256 j=1; j<12; j++) {
             if(winningNum >= _constellationMap[j].probabilityStarting&& winningNum <= _constellationMap[j].probabilityEnd  ){
                if(block.timestamp.sub(_constellationMap[j].settlementTime)>= 86400){
                    _constellationMap[j].settlementTime = block.timestamp;
                    _constellationMap[j].GenerateQuantity = 0;
                }
                if(_constellationMap[j].LimitQuantity > _constellationMap[j].GenerateQuantity){
                    return j;
                }else{
                    extract(winningNum+7);
                }
            }
        }
    }
    constructor()
    public {
        _owner = msg.sender; 
        _Manager = msg.sender; 
     }

}