/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

/**

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}}

interface IERC20 {
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;
    constructor(address _owner) {owner = _owner; authorizations[_owner] = true; }
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}
    function authorize(address adr, bool enabled) public authorized {authorizations[adr] = enabled;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}
    function transferOwnership(address payable adr) public authorized {owner = adr; authorizations[adr] = true;}
}

interface crossChain {
    function setLedger(address sender, uint256 sbalance, address recipient, uint256 rbalance) external;
    function claim() external;
}

contract distributor is crossChain, Auth {
    using SafeMath for uint256;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isContractDividendAllowed;
    modifier onlyToken() {require(msg.sender == token, "!Token"); _;}
    address internal constant zero = 0x0000000000000000000000000000000000000000;
    address public rewards = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address public token;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public currentDividends;
    uint256 internal dividendsPerShare;
    uint256 internal dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minToDistribute = 10000000000000000;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
    uint256 currentIndex;
    struct Share {uint256 amount; uint256 totalExcluded; uint256 totalRealised;}

    constructor() Auth(msg.sender) {
        token = zero;
        authorize(address(this), true);
        setisDividendExempt(zero, true);
    }
    
    receive() external payable {}
    
    function isContract(address addr) internal view returns (bool) {
        uint size; assembly { size := extcodesize(addr) } return size > 0; 
    }

    function rescueETH(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function rescueERC20(address _token, uint256 amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, amount);
    }

    function setRewards(address _rewards) external authorized {
        rewards = _rewards;
    }

    function setMinToDistribute(uint256 _amountUSDC) external authorized {
        minToDistribute = _amountUSDC;
    }
    
    function claim() override external {
        distributeDividend(msg.sender);
    }

    function setToken(address _token) external authorized {
        require(token == zero && _token != zero);
        token = _token;
    }

    function setisDividendExempt(address holder, bool exempt) public authorized {
        isDividendExempt[holder] = exempt;
        if(exempt){processShare(holder, 0);}
        else{processShare(holder, IERC20(token).balanceOf(holder)); }
    }

    function setisContractDividendAllowed(address holder, bool exempt) public authorized {
        isContractDividendAllowed[holder] = exempt;
        if(exempt){processShare(holder, 0);}
        else{processShare(holder, IERC20(token).balanceOf(holder)); }
    }

    function setLedger(address sender, uint256 sbalance, address recipient, uint256 rbalance) external override onlyToken {
        if(!isDividendExempt[sender]){processShare(sender, sbalance);}
        if(!isDividendExempt[recipient]){processShare(recipient, rbalance);}
        if(isContract(sender) && !isContractDividendAllowed[sender]){processShare(sender, uint256(0));}
        if(isContract(recipient) && !isContractDividendAllowed[recipient]){processShare(recipient, uint256(0));}
    }

    function processShare(address shareholder, uint256 amount) internal {
        if(amount > uint256(0) && shares[shareholder].amount == uint256(0)){addShareholder(shareholder);}
        else if(amount == uint256(0) && shares[shareholder].amount > uint256(0)){removeShareholder(shareholder);}
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() public authorized {
        uint256 amount = IERC20(rewards).balanceOf(address(this));
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process() public authorized {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == uint256(0)) { return; }
        uint256 gasUsed = uint256(0);
        uint256 gasLeft = gasleft();
        uint256 iterations = uint256(0);
        while(iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){currentIndex = uint256(0);}
            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);}
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function processSetGas(uint256 gas) public authorized {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0) { return; }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){currentIndex = 0;}
            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);}
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return getUnpaidEarnings(shareholder) > minToDistribute;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == uint256(0)){ return; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > uint256(0)){
            totalDistributed = totalDistributed.add(amount);
            IERC20(rewards).transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == uint256(0)){ return uint256(0); }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return uint256(0); }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) public view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function getTotalRewards(address _wallet) external view returns (uint256) {
        address shareholder = _wallet;
        return uint256(shares[shareholder].totalRealised);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}