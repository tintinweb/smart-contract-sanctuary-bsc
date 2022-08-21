/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

contract AnalogInceptive  {

   using SafeMath for uint256;
    address  public owner;

    struct Phase {
        string name;
        uint256 startBlock;
        uint256 endBlock;
        uint256 HCAmount;
        uint256 basePrice;
        uint256 totalTokenRealesed;
    }

    struct History {
        uint8 phaseId;
        uint256 amount;
        uint256 price;
        uint256 blockNumber;
    }

    struct User {
        History[] history;
        uint256 ttlPurchasedAmt;
    }

    mapping(uint8 => Phase) public phases;
    mapping(address =>User) public users;
    IERC20 public inrXToken;


    constructor(IERC20 _inrX, address payable ownerAddress) {
        owner = ownerAddress;  
        inrXToken = _inrX;

        phases[1].name="Gensis";
        phases[1].HCAmount=30000000 * 1e18;     
        phases[1].basePrice=1 * 1e18; 


        phases[2].name="Escaled";
        phases[2].HCAmount=40000000 * 1e18;     
        phases[2].basePrice=2 * 1e18; 


        phases[3].name="Revolt";
        phases[3].HCAmount=50000000 * 1e18;     
        phases[3].basePrice=4 * 1e18; 

        phases[4].name="Momentum";
        phases[4].HCAmount=30000000 * 1e18;     
        phases[4].basePrice=8 * 1e18; 

        phases[5].name="Markle";
        phases[5].HCAmount=40000000 * 1e18;     
        phases[5].basePrice=16 * 1e18; 
            
        phases[6].name="Exos";
        phases[6].HCAmount=50000000 * 1e18;     
        phases[6].basePrice=32 *1e18;


        phases[7].name="Integration";
        phases[7].HCAmount=60000000;     
        phases[7].basePrice=64 * 1e18; 
    }

    modifier onlyOwner {
      require(msg.sender == owner , "Only Owner Can Perform This Action");
      _;
    }

    function buyAna(uint256 _amount) public  returns(bool) {
        uint8 phaseId = getCurrentPhase();
        uint256 crntPrice = currentPrice();
        uint256 _inrxAmount = crntPrice.mul(_amount).div(1e18);
        require(phases[phaseId].totalTokenRealesed.add(_amount)<=phases[phaseId].HCAmount,"phase Ana sold out!");
        require(inrXToken.allowance(msg.sender,address(this))>=_inrxAmount,"allowance Exceed!");
        require(inrXToken.balanceOf(msg.sender)>=_inrxAmount,"allowance Exceed!");
        inrXToken.transferFrom(msg.sender,address(this),_inrxAmount);
        phases[phaseId].totalTokenRealesed=phases[phaseId].totalTokenRealesed.add(_amount);
        users[msg.sender].ttlPurchasedAmt=users[msg.sender].ttlPurchasedAmt.add(_amount);
        History memory history = History(phaseId, _amount,crntPrice,block.number);
        users[msg.sender].history.push(history);
        payable(msg.sender).transfer(_amount);

        ChangeTotalDistribuiton(_amount);


    }

    function getCurrentPhase() public view returns (uint8 phaseId) {
        uint blockNumber = block.number;
        for(uint8 i =1; i<=7; i++){
            if(phases[i].startBlock<=blockNumber && phases[i].endBlock>=blockNumber){
                phaseId=i;
            }
        }
    }

    function currentPrice() public view returns(uint256) {
        uint8 phaseId = getCurrentPhase();
        uint256 ttlTokenRealsed = phases[phaseId].totalTokenRealesed;
        uint256 percentSell = (ttlTokenRealsed.mul(100)).div(phases[phaseId].HCAmount).div(1e18);
        return phases[phaseId].basePrice.add((phases[phaseId].basePrice).mul(percentSell).div(100).div(1e18));
    } 

    function updateStartOrEndBlock(uint8 phaseId , uint256 _newStartBlock,uint256 _newEndBlock) external onlyOwner returns (bool) {
        require(phases[phaseId].HCAmount!=0,"invalid phaseId");
        phases[phaseId].startBlock = _newStartBlock;
        phases[phaseId].endBlock = _newEndBlock;
        return true;
    }


    function getUserHistory (address user, uint256 _index) external view returns(History memory){
        return users[user].history[_index];
    }

    function getUserTotalHistoryCount (address user) external view returns(uint256 ){
        return users[user].history.length;
    }

    function getUserTotalAmountBuy(address user) external view returns (uint256) {
        return users[user].ttlPurchasedAmt;
    }

     function ChangeTotalDistribuiton(uint256 _amountChange) public {

            _amountChange/100;
           for(uint8 j =1; j<=7; j++){
            phases[j].HCAmount ;
               
            
        

           }
     }

}