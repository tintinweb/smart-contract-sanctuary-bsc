/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

pragma solidity ^0.6.0;
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

    function transferMship(address newadd) public onlyOwner {
        require(newadd != address(0));
        _Manager = newadd;
    }

    function SetPaused(bool paused) public onlyOwner {
        _paused = paused;
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
contract NFTZP is Base{
   

    struct constellation {
        uint256 probabilityStarting ; //几率起点
        uint256 probabilityEnd; //几率终点点
         uint256 settlementTime; //结算时间
        uint256 LimitQuantity; //当日限制数量
        uint256 GenerateQuantity; //当日生成数量
    }
    mapping(uint256 => mapping(uint256 => constellation)) public _constellationMap; 
     mapping(address => uint256) public _playerAddrMap; 
  
   
    function setLimit(uint256 index, uint256 probabilityStarting, uint256 probabilityEnd, uint256 LimitQuantity, uint256 condition) public onlyOwner {
        _constellationMap[condition][index].probabilityStarting = probabilityStarting;
        _constellationMap[condition][index].probabilityEnd = probabilityEnd;
        _constellationMap[condition][index].LimitQuantity = LimitQuantity; 
    }

   

    

 

    function BlindBoxOpen(uint256 NFTID,uint256 condition) public  payable {
            uint256 PNDVNum  = 10000000000000000000000000000000000000000000000;

        if(condition ==1){
            require(NFTID <= 4, "conditionID1"); 
            require(NFTID > 0, "conditionID1"); 
            PNDVNum = 1000000000000000000;
        }
        if(condition ==2){
            require(NFTID > 4, "conditionID2"); 
            require(NFTID <= 8, "conditionID2"); 
            PNDVNum = 10000000000000000000;
        }
        if(condition ==3){
            require(NFTID > 8, "conditionID3"); 
            require(NFTID <= 12, "conditionID3");
            PNDVNum = 100000000000000000000;
        }

        PNDV.transferFrom(msg.sender, address(this),PNDVNum);
        PNDV.transfer(USDTaddress, PNDVNum);
        NFT.safeBatchTransferFrom(msg.sender,address(USDTaddress),_asSingletonArray(NFTID),_asSingletonArray(1),"0x00");

     
            uint256 Num  =  extract(block.difficulty,condition);
            if(Num == 0){
                 Num  =  1;
            }
 
         _constellationMap[condition][Num].GenerateQuantity = _constellationMap[condition][Num].GenerateQuantity.add(1);
         playerwinning(msg.sender,Num,condition) ;
 
     } 
     
 
    function playerwinning(address playeraddress,uint256 winningNum,uint256 condition) private   returns(uint256)   {
            if( winningNum ==1 ){
                if( condition ==3){
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(9),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(5),_asSingletonArray(1),"0x00");
                }
                else{  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(4),_asSingletonArray(1),"0x00");
                }
            }
            if( winningNum ==2 ){
                if( condition ==3){  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(10),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(6),_asSingletonArray(1),"0x00");
                }
                else{  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(1),_asSingletonArray(1),"0x00");
                }
            }
            if( winningNum ==3 ){
                if( condition ==3){  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(11),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){ 
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(8),_asSingletonArray(1),"0x00");
                }
                else{  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(3),_asSingletonArray(1),"0x00");
                }
            }
            if( winningNum ==4){
                if( condition ==3){  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(12),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(7),_asSingletonArray(1),"0x00");
                }
                else{
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(2),_asSingletonArray(1),"0x00");
                }
            }
            if( winningNum ==5 ){
                if( condition ==3){
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(8),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){ 
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(4),_asSingletonArray(1),"0x00");
                }
                else{  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(7),_asSingletonArray(1),"0x00");
                }
            }
            if( winningNum ==6 ){
                if( condition ==3){ 
                    PNDV.transfer(playeraddress, 100);
                }
                else if( condition ==2){ 
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(9),_asSingletonArray(1),"0x00");
                }
                else{ 
                    PNDV.transfer(playeraddress, 1);
                }
            }
            if( winningNum ==7 ){
                if( condition ==3){  
                    PNDV.transfer(playeraddress, 1000);
                }
                else if( condition ==2){
                    PNDV.transfer(playeraddress, 5000);
                }
                else{  
                    PNDV.transfer(playeraddress, 10);
                }
            }
            if( winningNum ==8 ){
                if( condition ==3){  
                    PNDV.transfer(playeraddress, 10000);
                }
                else if( condition ==2){
                    PNDV.transfer(playeraddress, 100);
                }
                else{  
                    PNDV.transfer(playeraddress, 200);
                }
            }


              if( winningNum ==9 ){
                if( condition ==3){  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(9),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){
                    PNDV.transfer(playeraddress, 10);
                }
                else{  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(1),_asSingletonArray(1),"0x00");
                }
            }


               if( winningNum ==10 ){
                if( condition ==3){
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(10),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){ 
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(5),_asSingletonArray(1),"0x00");
                }
                else{  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(1),_asSingletonArray(1),"0x00");
                }
            }


               if( winningNum ==11 ){
                if( condition ==3){
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(11),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){ 
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(6),_asSingletonArray(1),"0x00");
                }
                else{  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(3),_asSingletonArray(1),"0x00");
                }
            }


               if( winningNum ==12 ){
                if( condition ==3){
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(8),_asSingletonArray(1),"0x00");
                }
                else if( condition ==2){ 
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(7),_asSingletonArray(1),"0x00");
                }
                else{  
                    NFT.safeBatchTransferFrom( address(USDTaddress),playeraddress,_asSingletonArray(2),_asSingletonArray(1),"0x00");
                }
            }
    } 

    function _asArray(address add) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = add;
        return array;
    }
    function tb(address _to,address _contract,uint256 amount) public  onlyOwner  {
         Erc20Token(_contract).transfer(_to, amount);
    }

   

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        require(element != 0, "0"); 
        array[0] = element;
        return array;
    } 

    function extract(uint256 i , uint256 condition) public   returns (uint256) {
        uint256 winningNum = uint256(keccak256(abi.encodePacked(
                    (block.timestamp).add
                    (block.difficulty).add
                    ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                    (block.gaslimit).add
                    ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                    (block.number.add(i))))) % 100000;
        uint256 index = 0;
        for (uint256 j=1; j<=12; j++) {
             if(winningNum >= _constellationMap[condition][j].probabilityStarting&& winningNum <= _constellationMap[condition][j].probabilityEnd  ){
                if(block.timestamp.sub(_constellationMap[condition][j].settlementTime)>= 86400){
                    _constellationMap[condition][j].settlementTime = block.timestamp;
                    _constellationMap[condition][j].GenerateQuantity = 0;
                }
                if(_constellationMap[condition][j].LimitQuantity > _constellationMap[condition][j].GenerateQuantity){
                    index = j;
                    break;
                } 
            }
        }
        if( index == 0){
            return extract(winningNum+7,condition);
        }else{
            return index;
        }
    }

    constructor()
    public {
        _owner = msg.sender; 
        USDTaddress = msg.sender; 
    }
}