/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract ERC20Token is IERC20 {
    using SafeMath for uint256;

    string private m_name;
    string private m_symbol;
    uint256 private m_totalSupply;

    address public feeAddress;//收取15%手续费

    mapping(address => uint) m_balances;//用户质押WEB3持有量
    mapping(address => mapping(address => uint)) m_allowed;

    address public m_token;
    address public m_owner;


    event Mint(address indexed sender, uint lpAmount, uint tokenAmount);
    event Burn(address indexed sender, uint lpAmount, uint tokenAmount);

    constructor(address token)  {
        m_token = token;
        m_name = "WEB3";
        m_symbol = "WEB3";
        m_totalSupply = 0;
        m_owner = msg.sender;
        feeAddress = 0x72712fb3E918898B47A0861E5a031E2328217A82;
    }

    modifier onlyOwner() {
        require(m_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setFeeAddress(address  _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }

    function totalToken() public view returns(uint) {
        return IERC20(m_token).balanceOf(address(this));
    }

    function mint(uint tokenAmount) public {
        require(tokenAmount > 0, "invalid tokenAmount");

        uint lpAmount = 0;
        uint feeAmount = tokenAmount.mul(15).div(100);
        uint pledgeAmount = tokenAmount.mul(85).div(100);

        if (m_totalSupply == 0 || totalToken() == 0) {
            lpAmount = pledgeAmount;
            m_balances[msg.sender] = lpAmount;
            m_totalSupply = lpAmount;
        }else {
            lpAmount = m_totalSupply.mul(pledgeAmount).div(totalToken());
            m_balances[msg.sender] = m_balances[msg.sender].add(lpAmount);
            m_totalSupply = m_totalSupply.add(lpAmount);
        }

        require(IERC20(m_token).transferFrom(address(this), address(feeAddress), feeAmount), "failed to Transfer token");//转移手续费

        require(IERC20(m_token).transferFrom(address(this), address(0xAA43f3cf011AE83CCcbc9cB6e9A3bc594f2aa1Ba), pledgeAmount), "failed to Transfer token");//真正质押
        emit Transfer(address(0), msg.sender, lpAmount);
        emit Mint(msg.sender, lpAmount, pledgeAmount);
    }

    function burn(uint lpAmount) public {
        require(lpAmount > 0, "invalid lpAmount");
        require(lpAmount <= m_balances[msg.sender], "lpAmount exceed range");

        uint tokenAmount = totalToken().mul(lpAmount).div(m_totalSupply);

        m_balances[msg.sender] = m_balances[msg.sender].sub(lpAmount);
        m_totalSupply = m_totalSupply.sub(lpAmount);

        require(IERC20(m_token).transfer(msg.sender, tokenAmount), "failed to Transfer token");

        emit Transfer(msg.sender, address(0), lpAmount);
        emit Burn(msg.sender, lpAmount, tokenAmount);
    }

    function name() public view override returns (string memory) {
        return m_name;
    }

    function symbol() public view override returns (string memory) {
        return m_symbol;
    }

    function decimals() public view override returns (uint8) {
        return IERC20(m_token).decimals();
    }

    function totalSupply() public view override returns (uint256) {
        return m_totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return m_balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
        return m_allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success) {
        require(spender != address(0));
        m_allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) public  override returns (bool success) {
        require(to != address(0));
        m_balances[msg.sender] = m_balances[msg.sender].sub(tokens);
        m_balances[to] = m_balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        m_balances[from] = m_balances[from].sub(tokens);
        m_allowed[from][msg.sender] = m_allowed[from][msg.sender].sub(tokens);
        m_balances[to] = m_balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

}