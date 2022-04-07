/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.13;

abstract contract Context {

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
 
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
contract Rmath {

    function btoi(uint256 a)
        internal pure
        returns (uint256)
    {
        return a / 1e18;
    }

    function bfloor(uint256 a)
        internal pure
        returns (uint256)
    {
        return btoi(a) * 1e18;
    }

    function badd(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        (uint256 c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint256 a, uint256 b)
        internal pure
        returns (uint, bool)
    {
        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }


    function bmul(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        uint256 c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint256 c1 = c0 + (1e18 / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint256 c2 = c1 / 1e18;
        return c2;
    }

    function bdiv(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * 1e18;
        require(a == 0 || c0 / a == 1e18, "ERR_DIV_INTERNAL"); 
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL");
        uint256 c2 = c1 / b;
        return c2;
    }

    function bpowi(uint256 a, uint256 n)
        internal pure
        returns (uint256)
    {
        uint256 z = n % 2 != 0 ? a : 1e18;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

    function bpow(uint256 base, uint256 exp)
        internal pure
        returns (uint256)
    {
        require(base >= 1 wei, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= (2 * 1e18) - 1 wei, "ERR_BPOW_BASE_TOO_HIGH");

        uint256 whole  = bfloor(exp);
        uint256 remain = bsub(exp, whole);

        uint256 wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint256 partialResult = bpowApprox(base, remain, 1e18 / 1e10);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(uint256 base, uint256 exp, uint256 precision)
        internal pure
        returns (uint256)
    {
        uint256 a     = exp;
        (uint256 x, bool xneg)  = bsubSign(base, 1e18);
        uint256 term = 1e18;
        uint256 sum   = term;
        bool negative = false;


        for (uint256 i = 1; term >= precision; i++) {
            uint256 bigK = i * 1e18;
            (uint256 c, bool cneg) = bsubSign(a, bsub(bigK, 1e18));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }
}

interface DAO {    
    function isMod(address addy) external view returns(bool);
    function liveMods() external view returns(uint256);
    function appointModForVote(string memory _handle, address _wallet) external;
    function giveReward(address addy, uint256 amt) external;
}

interface BIG {
    function Karma(address addy) external view returns(uint256);
}

contract hp is Context, Rmath {    
    using SafeMath for uint256;
    using Address for address;

    struct marketing {
        uint256 claimID;
        uint256 amount;
        address destination;
        uint256 modUp;
        uint256 modDown;
        uint256 timeSubmitted;   
        bool live;     
    }

    struct CEX { //0x567a1976a618E7bb93751b1E348a72bD4930c159
        uint256 claimID;
        uint256 amount;
        address destination;
        uint256 modUp;
        uint256 modDown;
        uint256 timeSubmitted;    
        bool live;    
    }

    address public dao = 0x9dE39c5F767223Bef3dA8440C9d07C6F586f6732;
    address public $BIG = 0xEce5D9B94081827423C3b8409C5f262A7875e152;
    uint256 public marID = 0;
    uint256 public CEXID = 0;
    uint256 public marAmountHeld = 0;
    uint256 public CEXamountHeld = 0;
    mapping (uint256 => marketing) public mar;
    mapping (uint256 => CEX) public cex;
    mapping (address => mapping (uint256 => bool)) public modUpVoteMar;
    mapping (address => mapping (uint256 => bool)) public modUpVoteCEX;

    function appointMod(string memory _handle, address _wallet) external {
        require(DAO(dao).isMod(msg.sender) == true);
        require(msg.sender != _wallet, "Cant appoint self");
        require(BIG($BIG).Karma(_wallet) >= 1, "User has no karma");
        DAO(dao).appointModForVote(_handle, _wallet);
    }

    function generateMarketingClaim(uint256 claim, uint256 amt) public {
        require(msg.sender == dao);   
        marID += 1;
        mar[marID].claimID = claim;
        mar[marID].amount = amt;
        mar[marID].timeSubmitted = block.timestamp;
        marAmountHeld += amt;
    }

    function generateCEXClaim(uint256 claim, uint256 amt) public {
        require(msg.sender == dao);
        CEXID += 1;        
        mar[CEXID].claimID = claim;
        cex[CEXID].amount = amt;
        cex[CEXID].timeSubmitted = block.timestamp;
        CEXamountHeld += amt;
    }

    function setMarketingClaimDestinationVote(uint256 ID, address addy) external {
        require(DAO(dao).isMod(msg.sender) == true);
        require(mar[ID].destination == address(0));
        require(mar[ID].live == false);
        mar[ID].destination = addy;
        mar[ID].live = true;
    }

    function setCEXClaimDestinationVote(uint256 ID, address addy) external {
        require(DAO(dao).isMod(msg.sender) == true);
        require(cex[ID].destination == address(0));
        require(cex[ID].live == false);
        cex[ID].destination = addy;
        cex[ID].live = true;
    }

    function upVoteMarketingDestination(uint256 ID, uint256 select) external {        
        require(DAO(dao).isMod(msg.sender) == true, "Not mod");
        require(modUpVoteMar[msg.sender][ID] == false, "Already voted");
        require(select == 1 || select == 2, "1 for yes, 2 for no"); 
        require(mar[ID].live == true, "Not live");
        modUpVoteMar[msg.sender][ID] = true;
        if(select == 1) {
            mar[ID].modUp += 1;
        }
        else {
            mar[ID].modDown += 1;
        }
    }

    function upVoteCEXDestination(uint256 ID, uint256 select) external {        
        require(DAO(dao).isMod(msg.sender) == true, "Not mod");
        require(modUpVoteCEX[msg.sender][ID] == false, "Already voted");
        require(select == 1 || select == 2, "1 for yes, 2 for no"); 
        require(cex[ID].live == true, "Not live");
        modUpVoteCEX[msg.sender][ID] = true;
        if(select == 1) {
            cex[ID].modUp += 1;
        }
        else {
            cex[ID].modDown += 1;
        }
    }

    function sendMarketingDestination(uint256 ID) external {                     
        require(DAO(dao).isMod(msg.sender) == true, "Not mod");
        require(mar[ID].live == true, "Not live");
        uint256 tot = mar[ID].modUp + mar[ID].modDown;
        require(tot > 6, "7 votes required");
        address dest = mar[ID].destination;
        uint256 amt = mar[ID].amount;
        if(mar[ID].modUp > mar[ID].modDown) {
            mar[ID].amount = 0;
            mar[ID].live = false;
            marAmountHeld -= amt;
            _pushUnderlying($BIG, dest, amt);
        }
        if(mar[ID].modUp <= mar[ID].modDown) {
            mar[ID].live = false;
        }
        mar[ID].modUp = 0;
        mar[ID].modDown = 0;
        mar[ID].destination = address(0);
    }

    function sendCEXDestination(uint256 ID) external {                     
        require(DAO(dao).isMod(msg.sender) == true, "Not mod");
        require(cex[ID].live == true, "Not live");
        uint256 tot = cex[ID].modUp + cex[ID].modDown;
        require(tot > 6, "7 votes required");
        address dest = cex[ID].destination;
        uint256 amt = cex[ID].amount;
        if(cex[ID].modUp > cex[ID].modDown) {
            cex[ID].amount = 0;
            cex[ID].live = false;
            CEXamountHeld -= amt;
            _pushUnderlying($BIG, dest, amt);
        }
        if(cex[ID].modUp <= cex[ID].modDown) {
            mar[ID].live = false;
        }
        cex[ID].modUp = 0;
        cex[ID].modDown = 0;
        cex[ID].destination = address(0);
    }

    function _pushUnderlying(address erc20, address to, uint256 amount)
        internal 
    {   
        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer);
    }
}