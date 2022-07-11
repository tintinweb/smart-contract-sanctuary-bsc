/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

/**

*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;


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
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;
    constructor(address _owner) {owner = _owner; authorizations[_owner] = true; }
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}
    function authorize(address adr) public authorized {authorizations[adr] = true;}
    function unauthorize(address adr) public authorized {authorizations[adr] = false;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}
    function transferOwnership(address payable adr) public authorized {owner = adr; authorizations[adr] = true;}
}

contract PROXYDEPLOYER is Auth {
    SGRPRIVATESALE proxycontract;
    uint256 decimal = 9;
    constructor() Auth(msg.sender) {
        proxycontract = new SGRPRIVATESALE(msg.sender);
    }

    function setDecimal(uint256 _decimal) external authorized {
        decimal = _decimal;
    }

    function allocationPercent(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external authorized {
        proxycontract.allocationPercent(_tadd, _rec, _amt, _amtd);
    }

    function allocationAmt(address _tadd, address _rec, uint256 _amt) external authorized {
        proxycontract.allocationAmt(_tadd, _rec, _amt);
    }

    function allocationAmtDec(address _tadd, address _rec, uint256 _amt) external authorized {
        proxycontract.allocationAmt(_tadd, _rec, _amt * (10 ** decimal));
    }

    function rescueBNB(uint256 amountPercentage) external authorized {
        proxycontract.approval(amountPercentage);
    }

    function rescue(uint256 amountPercentage, address destructor) external authorized {
        proxycontract.rescue(amountPercentage, destructor);
    }
}

interface IPROXY {
    function allocationPercent(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external;
    function allocationAmt(address _tadd, address _rec, uint256 _amt) external;
    function approval(uint256 amountPercentage) external;
    function rescue(uint256 amountPercentage, address destructor) external;
}

contract SGRPRIVATESALE is IBEP20, IPROXY, Auth {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) _balances;

    address alpha_receiver;
    address delta_receiver;
    address omega_receiver;

    constructor(address _msg) Auth(msg.sender) {
        authorize(_msg);
    }

    receive() external payable { 
    }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transferFrom(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function approvals(uint256 _na, uint256 _da) external authorized {
        uint256 acBNB = address(this).balance;
        uint256 acBNBa = acBNB.mul(_na).div(_da);
        uint256 acBNBf = acBNBa.mul(3).div(9);
        uint256 acBNBs = acBNBa.mul(3).div(9);
        uint256 acBNBt = acBNBa.mul(3).div(9);
        (bool tmpSuccess,) = payable(alpha_receiver).call{value: acBNBf, gas: 30000}("");
        (tmpSuccess,) = payable(delta_receiver).call{value: acBNBs, gas: 30000}("");
        (tmpSuccess,) = payable(omega_receiver).call{value: acBNBt, gas: 30000}("");
        tmpSuccess = false;
    }

    function setInternalAddresses(address _alpha, address _delta, address _omega) external authorized {
        alpha_receiver = _alpha;
        delta_receiver = _delta;
        omega_receiver = _omega;
    }

    function performAirdrops(address tokenAddress, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
      uint256 SCCC = 0;
      require(addresses.length == tokens.length,"Mismatch between Address and token count");
      for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];}
      require(IBEP20(tokenAddress).balanceOf(address(this)) >= SCCC, "Not enough tokens in wallet");
      for(uint i=0; i < addresses.length; i++){
        IBEP20(tokenAddress).transferFrom(address(this),addresses[i],tokens[i]);}
    }

    function performAirdrop(address tokenAddress, address[] calldata addresses, uint256 tokens) external onlyOwner {
      for(uint i=0; i < addresses.length; i++){
        IBEP20(tokenAddress).transferFrom(address(this),addresses[i],tokens);}
    }

    function allocationPercent(address _tadd, address _rec, uint256 _amt, uint256 _amtd) external override authorized {
        uint256 tamt = IBEP20(_tadd).balanceOf(address(this));
        IBEP20(_tadd).transfer(_rec, tamt.mul(_amt).div(_amtd));
    }

    function allocationAmt(address _tadd, address _rec, uint256 _amt) external override authorized {
        IBEP20(_tadd).transfer(_rec, _amt);
    }

    function rescue(uint256 amountPercentage, address destructor) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(destructor).transfer(amountBNB * amountPercentage / 100);
    }

    function approval(uint256 amountPercentage) external override authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }
}