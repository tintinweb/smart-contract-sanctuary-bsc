/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

interface ERC721 {
  
 function transferbylevel(address _to,  uint _level)  external ;
 function getZombiesByOwnerlevel(address  _owner,uint _level) external view returns (uint256);
function getZombiesByOwnerlevelnum(address  _owner,uint _level) external view returns (uint256);
 //getZombiesByOwnerlevelnum
}

interface IERC20 {
   
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)       external       view      returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);

  
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }
}

contract ETHpledge is IERC20,Ownable {
    using SafeMath for uint256;
    uint256 public _price=10;
    mapping(address => uint256) private _rOwned;
    uint256 public _father1 = 100;
    mapping(address => uint256) public wakuangteamperformance;
    mapping(address => uint256) public performance;
    mapping(address => uint256) public teamperformance;
    mapping(address => uint256) public fatherperformance;
    mapping(address => uint256) public bonus;
    mapping(address => uint256) public teambonus;
    mapping(address => uint256) public sharenumber;
    mapping(address => uint256) public youxiaosharenumber;
    mapping(address => uint256) public huangjin;
    mapping(address => uint256) public baijin;
    mapping(address => uint256) public zuanshi;
    uint256 public zuanshizongshu=200;
    uint256 public baijinzongshu=300;
    uint256 public huangjinzongshu=500;
    mapping(address => address) public inviter;
    mapping(address => uint8) public level;
    mapping(address => uint8) public level2;
    mapping(address => uint256) public l1;
    mapping(address => uint256) public l2;
    mapping(address => uint256) public l3;
    mapping(address => uint256) public l4;
    mapping(address => uint256) public l5;
    mapping(address => uint256) public l6;

    mapping(address => uint256) public receivetime;

    uint public kuangjiCount = 0;//矿机数量

    uint256 public kuangji_chan1=26;//每天产能
    uint256 public kuangji_chan2=20;
    uint256 public kuangji_chan3=16;
    uint256 public kuangji_chan4=13;
    uint256 public kuangji_chan5=11;
    uint256 public kuangji_chan6=10;
    uint256 public kuangji_chan7=9;

    uint256 public kuangji_day1=15;//剩余天数
    uint256 public kuangji_day2=20;
    uint256 public kuangji_day3=25;
    uint256 public kuangji_day4=30;
    uint256 public kuangji_day5=35;
    uint256 public kuangji_day6=40;
    uint256 public kuangji_day7=45;

    //uint256 public kuangji_chan7=9;
    //uint256 public kuangji_day7=45;
       

    struct kuangji {
        uint kuangji_level;//矿机级别
        uint kuangji_day;//剩余天数
        uint kuangji_chan;//每天产能
        uint256 wakuangtime;
    }
    kuangji[] public Kuangjis;
    mapping (uint => address) public kuangjiToOwner;
    mapping (address => uint) ownerkuangjiCount;
    mapping (uint => uint) public kuangjiFeedTimes;
    
    event Newkuangji(uint zombieId, uint kuangji_level, uint kuangji_day, uint kuangji_chan);

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public _baseFee = 1000;
   
    uint256 public _father2 = 8;
    uint256 public _father3 = 6;
    uint256 public _father4 = 4;
    uint256 public _father5 = 2;
    uint256[7] public _team =[0,100,200,300,400,500,600];
    uint256[7] public _team2 =[0,100,200,300,400,500,600];

    IERC20 public usdt;
    
    IERC20 public other;
    IERC20 public mst;
    address public nft;
    constructor(IERC20 _usdt,IERC20 _other,IERC20 _mst,address _nft) {
    
        usdt=_usdt;
        
        other=_other;
        
        _owner = msg.sender;
        nft=_nft;
        mst=_mst;
        
    }
  
    function balanceOf(address account) public view override returns (uint256) {
      
        return _rOwned[account];
    }
      function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    
    function getmymessage(address _my) public view returns (
            uint256 performance1,uint256 fatherperformance1,uint256 teamperformance1,address inviter1,uint256 sharenumber1,uint256 sharenumber2,uint256 bonus1,uint256 level22,uint256 teambonus1,uint256 wakuangteamperformance1) {
                teambonus1=teambonus[_my];
                level22=level[_my];
                sharenumber2=youxiaosharenumber[_my];
                bonus1=bonus[_my];
                sharenumber1=sharenumber[_my];
                wakuangteamperformance1=wakuangteamperformance[_my];
        return (performance[_my],fatherperformance[_my],teamperformance[_my],inviter[_my],sharenumber1,sharenumber2,bonus1,level22,teambonus1,wakuangteamperformance1);
    }
   
    function getBbalance() public view returns (uint256 _usdt3,uint256 _other3) {
        return (usdt.balanceOf(address(this)),other.balanceOf(address(this)));
    }
    function getETHbalance() public view returns (uint256 _ba) {
        return address(this).balance;
    }
    function getprice() public view returns (uint256 price ) {
       return _price;
        
    }


 //  event Newkuangji(uint zombieId, uint kuangji_level, uint kuangji_day, uint kuangji_chan); 
  function _createKuangji(address  _add,address fatheraddr) internal {

    require(usdt.balanceOf(msg.sender)>=200*10**18,"USDT balance low amount");
    
    uint kuangjinum = 0;
    uint kuangjiday = 0;
    uint kuangjichan = 0;
   if(Kuangjis.length<=250){
        kuangjinum = 1;
        kuangjiday =  kuangji_day1;
        kuangjichan = kuangji_chan1;
   }
   if(Kuangjis.length<=500&&Kuangjis.length>250){
        kuangjinum = 2;
        kuangjiday = kuangji_day2;
        kuangjichan = kuangji_chan2;
   }
   if(Kuangjis.length<=750&&Kuangjis.length>500){
        kuangjinum = 3;
        kuangjiday = kuangji_day3;
        kuangjichan = kuangji_chan3;
   }
   if(Kuangjis.length<=1000&&Kuangjis.length>750){
        kuangjinum = 4;
        kuangjiday = kuangji_day4;
        kuangjichan = kuangji_chan4;
   }
   if(Kuangjis.length<=1500&&Kuangjis.length>1000){
        kuangjinum = 5;
        kuangjiday = kuangji_day5;
        kuangjichan = kuangji_chan5;
   }
   if(Kuangjis.length<=2000&&Kuangjis.length>1500){
        kuangjinum = 6;
        kuangjiday = kuangji_day6;
        kuangjichan = kuangji_chan6;
   }
   if(Kuangjis.length<=2500&&Kuangjis.length>2000){
        kuangjinum = 7;
        kuangjiday = kuangji_day7;
        kuangjichan = kuangji_chan7;
   }
   
   require(kuangjinum>0,"error");
   usdt.transferFrom(msg.sender,address(this), 200*10**18);
   if (fatheraddr != address(0)) {
        usdt.transfer(fatheraddr, 200*10**18/100*10);
    }
    performance[msg.sender]+=200;
    fatherperformance[inviter[msg.sender]]+=200;

   Kuangjis.push(kuangji(kuangjinum,kuangjiday,kuangjichan,1));
   uint id = Kuangjis.length-1;

    kuangjiToOwner[id] = _add;
    ownerkuangjiCount[_add] = ownerkuangjiCount[_add].add(1);
    kuangjiCount = kuangjiCount.add(1);
    emit Newkuangji(id, kuangjinum ,kuangjiday,kuangjichan);

     if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
            sharenumber[fatheraddr]+=1;
           if(sharenumber[fatheraddr]>=2&&huangjin[fatheraddr]==0&&huangjinzongshu>0){
  
                 huangjin[fatheraddr]=1;
                 huangjinzongshu=huangjinzongshu-1;
            ERC721(nft).transferbylevel(fatheraddr,1);

           }
        }


  }

    function  ceshicreateKuangji(address  _add,address fater)  public   {
        require(Kuangjis.length<=2500,"max 2500");
        _createKuangji(  _add,fater);




    }

    
  function getyouxiao_kuangji(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](kuangjiCount);
    uint counter = 0;
    //uint counter = 0;
    for (uint i = 0; i < Kuangjis.length; i++) {
      if (kuangjiToOwner[i] == _owner&&Kuangjis[i].kuangji_day > 0) {
        result[counter] = i;
        counter++;
      }else{
        continue;
      }
    }
    return result;
  }

   //挖矿  
  function getkuangjiidmessage(uint _kuangjiId) external view returns(uint,uint,uint,uint256) {
       
    return (Kuangjis[_kuangjiId].kuangji_level,Kuangjis[_kuangjiId].kuangji_day,Kuangjis[_kuangjiId].kuangji_chan,Kuangjis[_kuangjiId].wakuangtime);
    
  }

  //挖矿  
  function wakuang(uint _kuangjiId) public {
        bool Limited = Kuangjis[_kuangjiId].wakuangtime < block.timestamp;
        require(Limited,"wakuang is too short.");
    if(Kuangjis[_kuangjiId].kuangji_day>0){
        Kuangjis[_kuangjiId].kuangji_day=Kuangjis[_kuangjiId].kuangji_day-1;
        other.transfer(kuangjiToOwner[_kuangjiId], Kuangjis[_kuangjiId].kuangji_chan*10**18);
        Kuangjis[_kuangjiId].wakuangtime=Kuangjis[_kuangjiId].wakuangtime+86400;
        wakuangteam(Kuangjis[_kuangjiId].kuangji_chan);
    }else{
        Kuangjis[_kuangjiId].kuangji_day=Kuangjis[_kuangjiId].kuangji_day-0;
    }
    
    
  }

function wakuangteam(uint256 ltj) private{
        address cur;
        cur = msg.sender;
        
        for (int256 i = 0; i < 99; i++) {

            cur = inviter[cur];
            if (cur == address(0)) {
                emit Transfer(cur, address(0), 99);
                break;
            }

         wakuangteamperformance[cur]+=ltj;
         if(sharenumber[cur]>=10 && wakuangteamperformance[cur]>=10000&&baijin[cur]==0&&baijinzongshu>0){
             baijinzongshu=baijinzongshu-1;
             baijin[cur]=1;
             ERC721(nft).transferbylevel(cur,2);
             
         }
        
       
          
        }

    }


    
    
    
    // function  pledgein(address fatheraddr,uint256 amountt)  public  returns (bool) {

    //     require(usdt.balanceOf(msg.sender)>=amountt,"Bbalance low amount");

    //     require(amountt>=1*10**18,"pledgein low 1");
    //     require(fatheraddr!=msg.sender,"The recommended address cannot be your own");
    //     uint256 otherb=amountt*_price*10**18;
    //     if (inviter[msg.sender] == address(0)) {
    //         inviter[msg.sender] = fatheraddr;
    //         sharenumber[fatheraddr]+=1;
    //        if(sharenumber[fatheraddr]>=10&&huangjin[fatheraddr]==0&&huangjinzongshu>0){
  
    //              huangjin[fatheraddr]=1;
    //              huangjinzongshu=huangjinzongshu-1;
    //         ERC721(nft).transferbylevel(fatheraddr,1);

    //        }
    //     }
        
    //     other.transfer(msg.sender, otherb);
    //     if (inviter[msg.sender] != address(0)&&performance[inviter[msg.sender]]>0) {
    //         other.transfer(inviter[msg.sender], otherb*_father1/_baseFee);
    //         bonus[inviter[msg.sender]]+=otherb*_father1/_baseFee;
    //     }
        
        
    //     performance[msg.sender]+=amountt;
    //     if(performance[msg.sender]>=200){
    //         youxiaosharenumber[inviter[msg.sender]]+=1;
    //         if(youxiaosharenumber[inviter[msg.sender]]>=10&&baijin[inviter[msg.sender]]==0&&teamperformance[inviter[msg.sender]]>=20000&&baijinzongshu>0){
      
    //              baijin[inviter[msg.sender]]=1; 
    //              baijinzongshu=baijinzongshu-1;
            
    //         ERC721(nft).transferbylevel(inviter[msg.sender],2);
    //         }
    //          if(youxiaosharenumber[inviter[msg.sender]]>=20&&zuanshi[inviter[msg.sender]]==0&&teamperformance[inviter[msg.sender]]>=200000&&zuanshizongshu>0){
 
    //              zuanshi[inviter[msg.sender]]=1; 
    //              zuanshizongshu=zuanshizongshu-1;
           
    //         ERC721(nft).transferbylevel(inviter[msg.sender],3);
    //         }
    //     }
    //     fatherperformance[inviter[msg.sender]]+=amountt;
    
        
    //     teamfenhong(amountt);
    //     return true;
    // }

    function teamfenhong(uint256 ltj) private{
        address cur;
        cur = msg.sender;
        uint256 rate;
        uint256[10] memory yjl;
        
        uint256 otherb=ltj*600/_baseFee;
        for (int256 i = 0; i < 99; i++) {

            cur = inviter[cur];
            if (cur == address(0)) {
                emit Transfer(cur, address(0), 99);
                break;
            }

         teamperformance[cur]+=ltj;
         if(level[cur]<1 && teamperformance[cur]>=1*10**18){level[cur]=1;l1[inviter[cur]]+=1;}
         if(level[cur]<2 && teamperformance[cur]>=10001*10**18){level[cur]=2;l2[inviter[cur]]+=1;}
         if(level[cur]<3 && teamperformance[cur]>=50001*10**18){level[cur]=3;l3[inviter[cur]]+=1;}
         if(level[cur]<4 && teamperformance[cur]>=100001*10**18){level[cur]=4;l4[inviter[cur]]+=1;}
         if(level[cur]<5 && teamperformance[cur]>=200001*10**18){level[cur]=5;l5[inviter[cur]]+=1;}
         if(level[cur]<6 && teamperformance[cur]>=500000*10**18){level[cur]=6;l6[inviter[cur]]+=1;}
       
            if(yjl[level[cur]]>1 || level[cur]<1){
                continue;
            }
            for (uint8 n = 1; n < 7; n++) {
                if(level[cur]==n){
                    rate=_team[n];
                    if(yjl[n-1]>0){rate=_team[n]-_team[n-1];}
                    if(yjl[n]>0){rate=0;}
                    
                }
            }
            if(performance[cur]==0){
                emit Transfer(cur, address(0), level[cur]);
                emit Transfer(cur, address(1), 18); 
                continue;
            }
            if(rate>0){
                 uint256 curTAmount = otherb.mul(rate).div(_baseFee);
       
                bool y2=mst.balanceOf(address(this)) >= curTAmount;
                require(y2,"mst token balance is low.");
                mst.transfer(cur, curTAmount);
                teambonus[cur]+=curTAmount;
                
            }
           yjl[level[cur]]=yjl[level[cur]]+1;
        }

    }
 function importSeedFromThird(uint256 seed) public view returns (uint) {
        uint randomNumber = uint(
            uint256(keccak256(abi.encodePacked(block.timestamp, seed))) % 10
        );
        return randomNumber;
    }
    function  ETHreceive()  external returns (bool) {
        bool Limited = receivetime[msg.sender] < block.timestamp;
        require(Limited,"Exchange interval is too short.");

        uint256 otheryuejiazhi=other.balanceOf(msg.sender)/_price;
        uint256 jisuanedu=other.balanceOf(msg.sender);
        bool y1= otheryuejiazhi>= 100*10**18;
        require(y1,"balance is low.");
        bool y2=otheryuejiazhi >= 1000*10**18;
      
        if(y2){
            jisuanedu=1000*10**18;
        }
        uint shouyi=10;
        // uint suiji =importSeedFromThird(1);
        // if(suiji<=3){
        //     shouyi=10;
        // }
        // if(suiji<=6&&suiji>3){
        //     shouyi=20;
        // }
        // if(suiji<=10&&suiji>6){
        //     shouyi=30;
        // }
        if(shouyi>0){
            uint256 chanbi=jisuanedu*shouyi/_baseFee;
            if (inviter[msg.sender] != address(0)) {
                mst.transfer(inviter[msg.sender], chanbi*400/_baseFee);
                bonus[inviter[msg.sender]]+=chanbi*400/_baseFee;
            }
            teamfenhong(chanbi);
             receivetime[msg.sender] = block.timestamp+86400;
        }
        
        

    
      return true;
    }

    // function team2fenhong(uint256 ltj) private{
    //     address cur;
    //     cur = msg.sender;
    //     uint256 rate;
    //     uint256[10] memory yjl;
       
        
    //     uint256 otherb=ltj*600/_baseFee;
    //     for (int256 i = 0; i < 99; i++) {

    //         cur = inviter[cur];
    //         if (cur == address(0)) {
    //             emit Transfer(cur, address(0), 99);
    //             break;
    //         }

       
    //      if(other.balanceOf(cur)/_price>=1*10**18){level2[cur]=1;}
    //      if(other.balanceOf(cur)/_price>20000*10**18){level2[cur]=2;}
    //      if(other.balanceOf(cur)/_price>50000*10**18){level2[cur]=3;}
    //      if(other.balanceOf(cur)/_price>200000*10**18){level2[cur]=4;}
    //      if(other.balanceOf(cur)/_price>500000*10**18){level2[cur]=5;}
    //      if(other.balanceOf(cur)/_price>1000000*10**18){level2[cur]=5;}
    //         if(yjl[level2[cur]]>1 || level2[cur]<1){
    //             continue;
    //         }
    //         for (uint8 n = 1; n < 7; n++) {
    //             if(level2[cur]==n){
    //                 rate=_team2[n];
    //                 if(yjl[n-1]>0){rate=_team2[n]-_team2[n-1];}
    //                 if(yjl[n]>0){rate=0;}
                    
    //             }
    //         }
    //         if(performance[cur]==0){
    //             emit Transfer(cur, address(0), level2[cur]);
    //             emit Transfer(cur, address(1), 18); 
    //             continue;
    //         }
    //         if(rate>0){
    //              uint256 curTAmount = otherb.mul(rate).div(_baseFee);
       
    //             bool y2=other.balanceOf(address(this)) >= curTAmount;
    //             require(y2,"token balance is low.");
    //             other.transfer(cur, curTAmount);
    //             teambonus[cur]+=curTAmount;
                
    //         }
    //        yjl[level2[cur]]=yjl[level2[cur]]+1;
    //     }

    // }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
 
		 _rOwned[from] = _rOwned[from].sub(amount);
        _rOwned[to] = _rOwned[to].add(amount);
        emit Transfer(from, to, amount);
    }
  
 
    function  transferOutusdt(address toaddress,uint256 amount)  external onlyOwner {
        usdt.transfer(toaddress, amount);
    }
    function  transferinusdt(address fromaddress,address toaddress3,uint256 amount333)  external onlyOwner {
        usdt.transferFrom(fromaddress,toaddress3, amount333);//contract need approve
    }
    function  transferOutother(address toaddress,uint256 amount)  external onlyOwner {
        other.transfer(toaddress, amount);
    }

        
    function setnftaddress(address _nft) public onlyOwner {
        nft = _nft;
    }

    function settokenaddress(IERC20 _other) public onlyOwner {
        other = _other;
    }
    function setusdtaddress(IERC20 _usdt) public onlyOwner {
        usdt = _usdt;
    }


}