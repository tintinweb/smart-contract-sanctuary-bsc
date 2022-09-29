/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

pragma solidity <=0.8.0;

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
         function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
         function transferFrom(address _from, address _to, uint256 _value) external;
 

    }
 

    contract Base {
        using SafeMath for uint;
        Erc20Token   public USDT    = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
        IERC1155     public NFT     = IERC1155  (0xe8e1d14F445923688F3D4ED96d499E39191a8880);
        Erc20Token   public LP      = Erc20Token(0x0Eb537e5bE043bbbf2498A0345143fa80e4b7D4b);
        Erc20Token   public PNDV    = Erc20Token(0x7ab9F3367620eBdeCa38Db9b75e45971030eEA34);
        address public _owner;
        address  _Manager; 
        address USDTaddress; 
        bool public _paused = true;
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
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


    mapping(address => bool) public Owner_Principal;
     
    mapping(uint256 => uint256) public netAlltotle;

    mapping(uint256 => uint256) public NFTPrice; 
    uint256 public _startTime;
    uint256 public oneDay = 86400; 

    mapping(uint256 => uint256) public conditionLimit; 
    mapping(uint256 => uint256) public conditionLimitSZ; 

    mapping(uint256 => uint256) public code;
    mapping(uint256 => uint256) public startID;
    mapping(uint256 => uint256) public endID;



    uint256 public _playerCount; 
    mapping(uint256 => mapping(uint256 => address)) public codeIdToAddress;
    mapping(address => uint256) public _playerAddrMap; 
    mapping(uint256 => mapping(uint256 => uint256)) public everydaytotle;
    mapping(uint256 => Player) public _playerMap; 

 function Setcode(
        uint256  condition,
        uint256   data 
     ) public onlyOwner {
        code[condition] = data;
    } 
 
    function SetSilver(
        uint256    id,
        uint256  tpye,
        uint256  NFTID
     ) public onlyOwner {
            if(tpye == 0){
         _playerMap[id].goldnumber.push(NFTID);
        } if(tpye == 1){
            _playerMap[id].silvernumber.push(NFTID);
        } if(tpye == 2){
            _playerMap[id].bronzenumber.push(NFTID);
    
        }
    } 

function SetcodeIdToAddress(
        uint256[] calldata idS,
        uint256  condition,
        address[] calldata data 

  
        // uint256  index
     ) public onlyOwner {
        for (uint256 i=0; i<idS.length; i++) {
            uint256 id = idS[i];
 
           if(condition <=2){
                codeIdToAddress[condition][id]  = data[i];
                SetSilver(_playerAddrMap[ data[i]],condition,id);
           }else{
       
                address playerAddr = data[i];

               if(condition == 6){
 
                    _playerAddrMap[playerAddr]  =id;
                }else  if(condition == 7){
  
                
                    _playerMap[id].SJaddr = playerAddr; 
                }else  if(condition == 8){
 
                
                    _playerMap[id].addr = playerAddr; 
                }
           }
     
        }
    } 


    uint256 crystalPrice;  
    struct Player{
        address SJaddr; 
        address addr; 
        InvestInfo[]  silver; 
        uint256[]  silvernumber; 
        uint256[]  bronzenumber; 
        uint256[]   goldnumber; 
     }
     struct InvestInfo {
        uint256 id;  
        uint256 investAmt;  
        uint256 settlementDayNum;  
        uint256 PNDVQuantity;  
        uint256 produce;  
    }

 
    function set_playerCount(uint256 condition) public onlyOwner {
        _playerCount = condition;
 
    }

 
    function seeverydaytotle(uint256 index, uint256 condition,uint256 totle) public onlyOwner {
        everydaytotle[condition][index] = totle;
 
    }

    function setstartID(uint256 condition,uint256 codeID) public onlyOwner {
        startID[condition] = codeID;
 
    }



      function seteNDID(uint256 condition,uint256 codeID) public onlyOwner {
        endID[condition] = codeID;
 
    }


 

       function setPrincipalPL(address[] calldata account,bool B) public onlyOwner {
        for (uint256 m = 0; m < account.length; m++) {
            Owner_Principal[account[m]] = B;
        }

    }

  


    function registry(address playerAddr,address SJaddr ) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
                uint256  Daynumber = getdayNum( block.timestamp); 
                InvestInfo memory info = InvestInfo(_playerCount, 0,Daynumber, 0,  0);
                _playerMap[_playerCount].silver.push(info);
                _playerMap[_playerCount].silver.push(info);
                _playerMap[_playerCount].silver.push(info);
                _playerMap[_playerCount].SJaddr = SJaddr;
                _playerMap[_playerCount].addr = playerAddr;

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
            everydaytotle[NFTtype][Daynumber] =  netAlltotle[NFTtype];
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

    function settlement(uint256 condition ) public   {
        uint256 id = _playerAddrMap[msg.sender];
        uint256  Daynumber = getdayNum( block.timestamp); 
        if(_playerMap[id].silver[condition].settlementDayNum != Daynumber && _playerMap[id].silver[condition].investAmt > 0){
            js(msg.sender,Daynumber,condition);
        }
    }

     function Withdrawal(uint256 condition) public   {
        uint256 id = _playerAddrMap[msg.sender];
        require(_playerMap[id].silver[condition].produce  != 0, "produce is 0"); 
        address sjaddress =    _playerMap[id].SJaddr;
        uint256 UNum = _playerMap[id].silver[condition].PNDVQuantity.mul(10000000).div(price());
        if(_playerMap[id].silver[condition].PNDVQuantity>0){
            if( UNum < _playerMap[id].silver[condition].produce ){
                uint256 PNDVQuantity = _playerMap[id].silver[condition].PNDVQuantity.mul(10000000).div(price());
                PNDV.transferFrom(USDTaddress, msg.sender,PNDVQuantity.mul(9).div(10));
                PNDV.transferFrom(USDTaddress, sjaddress,PNDVQuantity.div(10));
                _playerMap[id].silver[condition].produce = _playerMap[id].silver[condition].produce.sub(UNum); 
                _playerMap[id].silver[condition].PNDVQuantity = 0;
            }else{
                uint256 PNum = _playerMap[id].silver[condition].produce.mul(price()).div(10000000);
                uint256  Daynumber = getdayNum( block.timestamp); 
                PNDV.transferFrom(USDTaddress, msg.sender,PNum.mul(9).div(10));
                PNDV.transferFrom(USDTaddress, sjaddress,PNum.div(10));
                netAlltotle[condition] = netAlltotle[condition].sub(_playerMap[id].silver[condition].investAmt);
                everydaytotle[condition][Daynumber] = netAlltotle[condition];
                _playerMap[id].silver[condition].PNDVQuantity = 0; 
                _playerMap[id].silver[condition].produce = 0; 
                _playerMap[id].silver[condition].investAmt = 0; 
            }
         }

    }

    function NFTmint(uint256[] memory  NFTID,uint256 condition,uint256 codeID) public  {
        require(codeID >= startID[condition], "codeID >"); 
        require(codeID <= endID[condition], "codeID <"); 
        require(msg.sender == codeIdToAddress[condition][codeID], "codeID ="); 
        uint256 id = _playerAddrMap[msg.sender];


        require(conditionLimit[condition] <= conditionLimitSZ[condition], "conditionLimit"); 
        conditionLimit[condition] = conditionLimit[condition].add(1);
        uint256  Daynumber = getdayNum( block.timestamp); 
        uint256 PNDVNum  = 10000000000000000000000000000000000000000000000;
        require(NFTID.length == condition + 1, "numberfil"); 
        uint256 tokenU =   0;
        uint256 NFTpriceAll  = 0;
        uint256 crystalU  = 0;

        for (uint256 j=0; j<NFTID.length; j++) {
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
         removeSr( condition,  codeID);
        uint256 crystalNum  = 0;
         if(condition ==2){
            PNDVNum = 100000000000000000000;

                      
            crystalNum = 3;
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

        uint256[] memory Quantityarray = new uint256[](NFTID.length);
        for (uint256 j=0; j<NFTID.length; j++) {
             Quantityarray[j] = 1;
        }
        NFT.safeBatchTransferFrom(msg.sender,address(USDTaddress),NFTID,Quantityarray,"0x00");
        NFT.safeBatchTransferFrom(msg.sender,address(USDTaddress),_asSingletonArray(15),_asSingletonArray(crystalNum),"0x00");
        NFTpriceAll = NFTpriceAll.add(crystalU).add(tokenU);
        if(_playerMap[id].silver[condition].settlementDayNum != Daynumber && _playerMap[id].silver[condition].investAmt > 0){
            js(msg.sender,Daynumber,condition);
        }else{
            _playerMap[id].silver[condition].settlementDayNum = Daynumber;

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
        netAlltotle[condition] = netAlltotle[condition].add(NFTpriceAll);
        everydaytotle[condition][Daynumber] = netAlltotle[condition];
        codeIdToAddress[condition][codeID] = address(0);
        uint256 idd  = 18;
        idd  = idd.sub(condition);
        uint256[] memory num  = _asSingletonArray(1);
        uint256[] memory NftID  = _asSingletonArray(idd);

        NFT.mintBatch2( _asArray(msg.sender),NftID,num);
    }
 
    function makeAnAppointment(uint256 condition,address SJaddr) public{


        require(Owner_Principal[SJaddr], "Owner_Principal");


        registry(msg.sender,SJaddr);
        code[condition] = code[condition].add(1);
        uint256 PNDVNum  = 10000000000000000000000000000000000000000000000;
        uint256 id = _playerAddrMap[msg.sender];

        if(condition ==2){
            PNDVNum  = 100000000000000000000;
            require(_playerMap[id].bronzenumber.length < 10, "bronzenumber 10"); 
            _playerMap[id].bronzenumber.push(code[condition]);
         }
        if(condition ==1){
            require(_playerMap[id].silvernumber.length < 5, "silvernumber 5"); 
            _playerMap[id].silvernumber.push(code[condition]);
            PNDVNum  = 500000000000000000000;
         }
        if(condition ==0){
            require(_playerMap[id].goldnumber.length < 2, "goldnumber 2"); 
            _playerMap[id].goldnumber.push(code[condition]);
            PNDVNum  = 1000000000000000000000;
        }
        PNDV.transferFrom(msg.sender, address(this),PNDVNum);
        PNDV.transfer(USDTaddress, PNDVNum);

        codeIdToAddress[condition][code[condition]] = msg.sender;
    }

 function getIndex(uint256 IDD,uint256 condition,uint256 codeID) private view returns (uint256) {
    
        uint256 Index = 10000000000000000000000000000000000000000000;
        if(condition == 2){
            for (uint256 i = 0; i < _playerMap[IDD].bronzenumber.length; i++) {
                if(_playerMap[IDD].bronzenumber[i] == codeID){
                    Index = i;
                }
            }
        }
        if(condition == 1){
            for (uint256 i = 0; i < _playerMap[IDD].silvernumber.length; i++) {
                if(_playerMap[IDD].silvernumber[i] == codeID){
                    Index = i;
                }
            }
        }
          if(condition == 0){
            for (uint256 i = 0; i < _playerMap[IDD].goldnumber.length; i++) {
                if(_playerMap[IDD].goldnumber[i] == codeID){
                    Index = i;
                }
            }
        }
        return Index;
    }

    function removeID(uint256 condition,uint256 codeID) public  onlyOwner{

        uint256 PNDVNum  = 10000000000000000000000000000000000000000000000;

        if(codeIdToAddress[condition][codeID] != address(0)){
            if(condition ==2){
                PNDVNum  = 100000000000000000000;
                }
            if(condition ==1){
                    PNDVNum  = 500000000000000000000;
                }
            if(condition ==0){
                    PNDVNum  = 1000000000000000000000;
            }
            PNDV.transferFrom(USDTaddress, codeIdToAddress[condition][codeID],PNDVNum);


        

            removeSr(  condition,  codeID);
     
        }



        if(PNDVNum  != 10000000000000000000000000000000000000000000000){
            codeIdToAddress[condition][codeID] = address(0);

        }



        
    }


     function RcodeIdToAddress(uint256 condition,uint256 codeID) public  onlyOwner{
 
            removeSr(  condition,  codeID);

            codeIdToAddress[condition][codeID] = address(0);
        
    }


    function removeSr(uint256 condition,uint256 codeID) internal  {
        uint256 IDD = _playerAddrMap[codeIdToAddress[condition][codeID]];
        uint256 Index = getIndex(IDD,condition,codeID);
         require(Index < 10000000000000000000000000000000000000000000, "getIndex"); 

        if(condition ==2){
            _playerMap[IDD].bronzenumber[Index] = _playerMap[IDD].bronzenumber[_playerMap[IDD].bronzenumber.length-1];
            _playerMap[IDD].bronzenumber.pop();
        }
        if(condition ==1){
            _playerMap[IDD].silvernumber[Index] = _playerMap[IDD].silvernumber[_playerMap[IDD].silvernumber.length-1];
            _playerMap[IDD].silvernumber.pop();
        }
        if(condition ==0)
        {
            _playerMap[IDD].goldnumber[Index] = _playerMap[IDD].goldnumber[_playerMap[IDD].goldnumber.length-1];
            _playerMap[IDD].goldnumber.pop();
        }
    }

    function _asArray(address add) private pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = add;
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
            return _playerMap[id].silver[condition];
        }else{
        return InvestInfo(0, 0,0, 0,  0);
        }
    }

 




 
 
    function SetInvestInf1(
        uint256[] calldata idS,
        uint256[] calldata  data,
        uint256  tpye,
        uint256  index
     ) public onlyOwner {
        for (uint256 i=0; i<idS.length; i++) {
            uint256 id = idS[i];


        if(tpye == 1){
            _playerMap[id].silver[index].investAmt = data[i];
        } if(tpye == 2){
             _playerMap[id].silver[index].settlementDayNum =  data[i];
        } if(tpye == 3){
                _playerMap[id].silver[index].PNDVQuantity =  data[i];
        } if(tpye == 4){
             _playerMap[id].silver[index].produce =  data[i];
        } if(tpye == 5){
             _playerMap[id].silver[index].id = id;
        } 
    
        }
    }

 
    function Setregistry(
        uint256  tpyeO, 
        uint256  tpyeE 
     ) public onlyOwner {
        for (uint256 i=tpyeO; i<tpyeE; i++) {
                InvestInfo memory info = InvestInfo(i, 0,0, 0,0);
                _playerMap[i].silver.push(info);
                _playerMap[i].silver.push(info);
                _playerMap[i].silver.push(info);
         }
    } 

   
 
 
 

    function getUserID(uint256 condition, address playerAddr) public view  returns (uint256[] memory) {
        uint256 id = _playerAddrMap[playerAddr];
 
        if(id > 0){
            if(condition ==2){
                return _playerMap[id].bronzenumber;
            }
            if(condition ==1){
                return _playerMap[id].silvernumber;
                }
            if(condition ==0){
                return _playerMap[id].goldnumber;
            }
      
        }
             return new uint256[](1);
    } 

    constructor()
    public {
        _owner = msg.sender; 
        USDTaddress = msg.sender;
        _startTime = block.timestamp; 

    }

}