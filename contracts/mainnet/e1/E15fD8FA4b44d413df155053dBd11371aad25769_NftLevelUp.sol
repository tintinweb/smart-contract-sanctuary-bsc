/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed
    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }
        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }
    }

    interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;





    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    function mintBatch2(
        address[] memory accounts,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;



}



    interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);

    }

    

 

// 基类合约

    contract Base {

        using SafeMath for uint;
        Erc20Token   public USDT    = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
        // IERC1155     public NFT     = IERC1155  (0xe8e1d14F445923688F3D4ED96d499E39191a8880);
        // Erc20Token   public LP      = Erc20Token(0x0Eb537e5bE043bbbf2498A0345143fa80e4b7D4b);
        // Erc20Token   public PNDV    = Erc20Token(0x7ab9F3367620eBdeCa38Db9b75e45971030eEA34);


        IERC1155     public NFT     = IERC1155  (0x63C4Ac0e3dA53d08227956Bf3Ce29bF28e6598f2);
        Erc20Token   public LP      = Erc20Token(0xB26167D8D02C3Cda4224B8A9bAEA59505985D460);
        Erc20Token   public PNDV    = Erc20Token(0xebF68288aA0496fA2AADa289Ea8969Ab84A291a0);



        address public _owner;
        address  _Manager; 
        address USDTaddress; 
        bool public _paused = true;

        function Convert(uint256 value) internal pure returns(uint256) {
            return value.mul(1000000000000000000);
        }
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }
        modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function transfeUSDTship(address newadd) public onlyOwner {
        require(newadd != address(0));
        USDTaddress = newadd;
    }

 

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function price() public view returns(uint256)   {
        uint256 usdtBalance = USDT.balanceOf(address(LP));
        uint256 PNDVBalance = PNDV.balanceOf(address(LP));
 

        if(usdtBalance == 0){
         return 0;
        }else{
         return PNDVBalance.mul(10000000).div(usdtBalance);
        }
    }  
    receive() external payable {}  
}

contract NftLevelUp is Base{

    using SafeMath for uint;
    mapping(uint256 => uint256) public produce; 
    mapping(uint256 => mapping(uint256 => uint256)) everydaytotle;
    mapping(address => bool) public _isWhiteList;

    mapping(address => uint256) public _playerAddrMap; 
    mapping(uint256 => uint256) public NFTPrice; 
    uint256 public _playerCount; 
    mapping(uint256 => Player) public _playerMap; 
    uint256 public _startTime;
    uint256 public oneDay = 600; 

    mapping(uint256 => uint256) public conditionLimit; 
    mapping(uint256 => uint256) public conditionLimitSZ; 


    uint256 crystalPrice;  
    struct Player{
        uint256 id; 
        address addr; 
         InvestInfo[]  silver; 
     }

    struct InvestInfo {
        uint256 id;  
        uint256 investAmt;  
        uint256 settlementDayNum;  
        uint256 PNDVQuantity;  
        uint256 produce;  
    }
    function setWhiteList(address account) public onlyOwner {
        _isWhiteList[account] = true;
    }


    modifier onlyWhiteList() {
        require(_isWhiteList[msg.sender], "Ownable: caller is not the owner");
        _;
    }
    function registry(address playerAddr ) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
                uint256  Daynumber = getdayNum( block.timestamp); 
                InvestInfo memory info = InvestInfo(_playerCount, 0,Daynumber, 0,  0);
               _playerMap[_playerCount].silver.push(info);
                _playerMap[_playerCount].silver.push(info);
                _playerMap[_playerCount].silver.push(info);
        }
    }

    function getdayNum(uint256 time) public view returns(uint256) {
        return (time.sub(_startTime)).div(oneDay);
    }
    function js(address playerAddr,uint256 Daynumber,uint256 NFTtype) internal{
        uint256 daytotle = 0;
        uint256 id = _playerAddrMap[playerAddr];
        uint256 investAmt = _playerMap[id].silver[NFTtype].investAmt;
        uint256 PNDVQuantity = 0;
        for (uint256 m = _playerMap[id].silver[NFTtype].settlementDayNum; m < Daynumber; m++) {
            if(everydaytotle[NFTtype][m] == 0)
            {
                everydaytotle[NFTtype][m] = daytotle;
            }
            else
            {
                daytotle = everydaytotle[NFTtype][m];
            }
            PNDVQuantity =PNDVQuantity.add(investAmt.mul(produce[NFTtype]).div(daytotle));

        }
        if(everydaytotle[NFTtype][Daynumber] == 0){
            everydaytotle[NFTtype][Daynumber] = daytotle;
        }



        _playerMap[id].silver[NFTtype].PNDVQuantity = _playerMap[id].silver[NFTtype].PNDVQuantity.add(PNDVQuantity);
        _playerMap[id].silver[NFTtype].settlementDayNum = Daynumber;
     }




    function setLimit(uint256 index, uint256 price) public onlyOwner {
        NFTPrice[index] = price;
    }

    function setproduce(uint256 index, uint256 price) public onlyOwner {
        produce[index] = price;
    }

  function setcrystalPrice( uint256 price) public onlyOwner {
      crystalPrice  = price;
    }


    function setconditionLimitSZ( uint256 condition,uint256 Quantity) public onlyOwner {
      conditionLimitSZ[condition]  = Quantity;
    }


    function settlement(uint256 condition ) public  onlyWhiteList() {
        uint256 id = _playerAddrMap[msg.sender];
        uint256  Daynumber = getdayNum( block.timestamp); 

        if(_playerMap[id].silver[condition].settlementDayNum != Daynumber){
            js(msg.sender,Daynumber,condition);
        }
    }

     function Withdrawal(uint256 condition) public  onlyWhiteList() {

        uint256 id = _playerAddrMap[msg.sender];
        require(_playerMap[id].silver[condition].produce  != 0, "produce is 0"); 

         if(_playerMap[id].silver[condition].PNDVQuantity>0){


         if( _playerMap[id].silver[condition].PNDVQuantity < _playerMap[id].silver[condition].produce ){

            PNDV.transferFrom(USDTaddress, msg.sender,_playerMap[id].silver[condition].PNDVQuantity);

 
            _playerMap[id].silver[condition].produce = _playerMap[id].silver[condition].produce.sub(_playerMap[id].silver[condition].PNDVQuantity); 
  

            _playerMap[id].silver[condition].PNDVQuantity = 0;

         }else{
            PNDV.transferFrom(USDTaddress, msg.sender,_playerMap[id].silver[condition].produce);


            _playerMap[id].silver[condition].PNDVQuantity = 0; 
            _playerMap[id].silver[condition].produce = 0; 

         }
         
         
         }

    }

     function NFTmint(uint256[] memory  NFTID,uint256 condition) public  onlyWhiteList() {
         registry(msg.sender);

        
        require(conditionLimit[condition] <= conditionLimitSZ[condition], "conditionLimit"); 
        conditionLimit[condition] = conditionLimit[condition].add(1);

        uint256  Daynumber = getdayNum( block.timestamp); 
        uint256 PNDVNum  = 10000000000000000000000000000000000000000000000;
        require(NFTID.length == condition + 1, "numberfil"); 
        uint256 tokenU =   0;
        uint256 NFTpriceAll  = 0;
        uint256 crystalU  = 0;

        for (uint256 j=0; j<=condition; j++) {
         if(condition ==2){
            require(NFTID[j] <= 4, "conditionID1"); 
            require(NFTID[j] > 0, "conditionID1"); 
         }
        if(condition ==1){
            require(NFTID[j] > 4, "conditionID2"); 
            require(NFTID[j] <= 8, "conditionID2"); 
         }
        if(condition ==0){
            require(NFTID[j] > 8, "conditionID3"); 
            require(NFTID[j] <= 12, "conditionID3");
        }
        NFTpriceAll = NFTpriceAll.add(NFTPrice[NFTID[j]]);
        }
        uint256 crystalNum  = 0;
         if(condition ==2){
            PNDVNum = 100000000000000000000;
            crystalNum = 7;
        }
        if(condition ==1){
            PNDVNum = 500000000000000000000;
            crystalNum = 2;
        }
        if(condition ==0){
            PNDVNum = 1000000000000000000000;
            crystalNum = 1;

        }

 

        crystalU = crystalNum.mul(crystalPrice);
        tokenU =     PNDVNum.mul(10000000).div(price());
        PNDV.transferFrom(msg.sender, address(this),PNDVNum);
        PNDV.transfer(USDTaddress, PNDVNum);


         uint256[] memory Quantityarray = new uint256[](NFTID.length);
        for (uint256 j=0; j<NFTID.length; j++) {
             Quantityarray[j] = 1;
        }
        NFT.safeBatchTransferFrom(msg.sender,address(USDTaddress),NFTID,Quantityarray,"0x00");
        NFT.safeBatchTransferFrom(msg.sender,address(USDTaddress),_asSingletonArray(15),_asSingletonArray(crystalNum),"0x00");
        NFTpriceAll = NFTpriceAll.add(crystalU).add(tokenU);
        uint256 id = _playerAddrMap[msg.sender];
        if(_playerMap[id].silver[condition].settlementDayNum != Daynumber){
            js(msg.sender,Daynumber,condition);
        }


        uint256 free = 0;

        if(condition ==2){
            free = 2;

          }
        if(condition ==1){
            free = 3;

          }

        if(condition ==0){
            free = 5;

         }

        _playerMap[id].silver[condition].investAmt = _playerMap[id].silver[condition].investAmt.add(NFTpriceAll);
        _playerMap[id].silver[condition].produce = _playerMap[id].silver[condition].produce.add(NFTpriceAll.mul(free));
        everydaytotle[condition][Daynumber] = everydaytotle[condition][Daynumber].add(NFTpriceAll);
      } 

    function _asArray(address add) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = add;
        return array;
    }
 
    function _asSingletonArray111(uint256 element,uint256 size) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](size.add(1));
        require(element != 0, "0"); 


                for (uint256 j=0; j<=size; j++) {
                    array[j] = element;

                }

        return array;
    }

  function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        require(element != 0, "0"); 
        array[0] = element;
        return array;
    }


    function getInvestInfo(uint256 condition,address playerAddr) public view returns(InvestInfo memory ) {
        uint256 id = _playerAddrMap[playerAddr];

        if(id > 0){
                    return    _playerMap[id].silver[condition];

        }else{


 
        return    InvestInfo(0, 0,0, 0,  0);

        }


     } 
    constructor()
    public {
        _owner = msg.sender; 
        USDTaddress = msg.sender;
        _startTime = block.timestamp; 

    }

}