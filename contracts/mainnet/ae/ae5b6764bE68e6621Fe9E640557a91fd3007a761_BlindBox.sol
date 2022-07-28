/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-28
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


    contract Base {
        using SafeMath for uint;
        IERC1155     public NFT     = IERC1155  (0x63C4Ac0e3dA53d08227956Bf3Ce29bF28e6598f2);
        Erc20Token   public PNDV    = Erc20Token(0xebF68288aA0496fA2AADa289Ea8969Ab84A291a0);
         address public _owner;
        address NFTaddress = 0xebF68288aA0496fA2AADa289Ea8969Ab84A291a0; 
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
        }



    function transfeUSDTship(address newadd) public onlyOwner {
        require(newadd != address(0));
        NFTaddress = newadd;

    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
}


contract BlindBox is Base{

    struct InvestInfo {
        uint256 id; // 
        uint256 rewardPNDV; // 
        uint256 Ptime; // 

    }


        uint256 public Marss = 0; // 

            uint256 public Venuss = 0; // 

    modifier  isMars() {
            require(Marss < 6000, "600"); _; 
        }



          modifier isVenus() {
            require(Venuss < 600, "600"); _; 
        }
        uint256 oneday = 100; // 

    mapping(uint256 => InvestInfo) public _playerMap; 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount; 
    function registry(address playerAddr) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
            _playerMap[_playerCount].id = _playerCount; 

        }

    }
    function synthesisMars(uint256 idType) public  isMars(){
        uint256[] memory IDarray = new uint256[](8);
        uint256[] memory Quantityarray = new uint256[](8);
        if(idType == 1){
        for (uint256 j=0; j<8; j++) {
            IDarray[j] = j.add(1);
            Quantityarray[j] = 1;
        }
}else if(idType == 2){
        for (uint256 j=0; j<8; j++) {
            IDarray[j] = j.add(1).add(4);
            Quantityarray[j] = 1;
        }
 }else{
        for (uint256 j=0; j<4; j++) {
            IDarray[j] = j.add(1);
            IDarray[j.add(4)] = j.add(1).add(8);
            Quantityarray[j] = 1;
            Quantityarray[j.add(4)] = 1;
        }
}
        NFT.safeBatchTransferFrom( msg.sender,NFTaddress,IDarray,Quantityarray,"0x00");
        registry(msg.sender);
        uint256 id = _playerAddrMap[msg.sender];
        if(block.timestamp.sub(_playerMap[id].Ptime)>oneday&&_playerMap[id].rewardPNDV > 0){
        settleStaticPNDV();
    }
        _playerMap[id].rewardPNDV = _playerMap[id].rewardPNDV.add(10000000000000000000000); 
       _playerMap[id].Ptime = block.timestamp;
        NFT.mintBatch2( _asArray(msg.sender),_asSingletonArray(15),_asSingletonArray(100));
Marss = Marss.add(1);
    }
    function synthesisVenus() public    isVenus {
        require( playerBlindBox(msg.sender,12), "Pausable: not paused");
        uint256[] memory IDarray = new uint256[](12);
        uint256[] memory Quantityarray = new uint256[](12);
        for (uint256 j=0; j<12; j++) {
            IDarray[j] = j.add(1);
            Quantityarray[j] = 1;
        }
        NFT.safeBatchTransferFrom( msg.sender,NFTaddress,IDarray,Quantityarray,"0x00");
        registry(msg.sender);

        uint256 id = _playerAddrMap[msg.sender];




    if(block.timestamp.sub(_playerMap[id].Ptime)>oneday&&_playerMap[id].rewardPNDV > 0){
        settleStaticPNDV();
    }
        _playerMap[id].rewardPNDV = _playerMap[id].rewardPNDV.add(50000000000000000000000); 
       _playerMap[id].Ptime = block.timestamp;


        NFT.mintBatch2( _asArray(msg.sender),_asSingletonArray(15),_asSingletonArray(1000));
        Venuss = Venuss.add(1);

    }







 function playerBlindBox(address add,uint256 idjudge) public view returns(bool)   {



        bool PD = true;

        for (uint256 j=1; j<=idjudge; j++) {

            if(NFT.balanceOf( add,j) == 0){

                PD = false;

            }   

        }

        return PD;

    } 

 


    function settleStaticPNDV() public      {
        uint256 id = _playerAddrMap[msg.sender];
        InvestInfo memory investList = _playerMap[id];
        uint256 staticaAmount = 0;
        uint256 lsrewardPNDV = investList.rewardPNDV;
        uint256 daynum = block.timestamp.sub(investList.Ptime);
        require(daynum > oneday, " time field" ); 
        require(investList.rewardPNDV > 0, " rewardPNDV field" ); 
        for (uint256 i = 0; i < daynum.div(oneday); i++) {
            uint256 dayd = lsrewardPNDV.mul(3).div(1000);
            staticaAmount = staticaAmount.add(dayd);    
            lsrewardPNDV = lsrewardPNDV.sub(dayd);
        }
        require(staticaAmount > 0, " Amount field" ); 
        PNDV.transfer(address(msg.sender), staticaAmount);
       _playerMap[id].rewardPNDV = lsrewardPNDV;
       _playerMap[id].Ptime = block.timestamp;
    }

    function _asArray(address add) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = add;
        return array;
    }

  function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](8);
        array[0] = element;
        return array;
    } 
  constructor()
    public {
        _owner = msg.sender; 
    }







}