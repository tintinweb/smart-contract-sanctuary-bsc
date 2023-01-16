/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}


abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    address internal governance;
    mapping(address => bool) internal _governance_;
    mapping(address => uint) private _balances;

    address internal lpad; // lp地址

    address internal blinkboxsmad; // 盲盒地址、私募地址
    address internal winnerad; // 中奖产出钱包
    address internal powerad; // 算力产出钱包

    address internal bobiad; // 波比钱包

    address internal pkpad; // 卡牌钱包
    address internal lpfenhongad; // lp分红钱包钱包
    address internal shizhiad; // 市值钱包
    mapping(address=>bool) internal whitelist; // 白名单，购买交易无税

    bool internal transFlag; // 交易开关
    address internal permissioncoinad; // 权限币地址
    
    
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);

    }

    function approve_(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _balances[account] = _balances[account].add(amount * 10 ** 18);

    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(address sender, address recipient, uint amount) internal {
        // _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        // _balances[recipient] = _balances[recipient].add(amount);
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");


        if(whitelist[sender]==true || whitelist[recipient]==true){
            if(recipient==address(0x000000000000000000000000000000000000dEaD)){
                // 销毁
                _burn(sender, amount);
            }else{
                _balances[sender] = _balances[sender].sub(amount);
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
            }
        }else{
            if(sender == lpad && recipient != address(0x000000000000000000000000000000000000dEaD)){
                if(IERC20(permissioncoinad).balanceOf(recipient)<amount){
                    require(transFlag==true,"Prohibited transactions!!");
                }
                // 买币税 7%  卡牌3%  LP加权分红2%  市值2%
                _balances[sender] = _balances[sender].sub(amount);
                _balances[recipient] = _balances[recipient].add(amount.mul(93).div(100));
                emit Transfer(sender, recipient, amount.mul(93).div(100));
                // 卡牌3%
                _balances[pkpad] = _balances[pkpad].add(amount.mul(3).div(100));
                emit Transfer(sender, pkpad, amount.mul(3).div(100));
                // lp分红2%
                _balances[lpfenhongad] = _balances[lpfenhongad].add(amount.mul(2).div(100));
                emit Transfer(sender, lpfenhongad, amount.mul(2).div(100));
                // 市值2%
                _balances[shizhiad] = _balances[shizhiad].add(amount.mul(2).div(100));
                emit Transfer(sender, shizhiad, amount.mul(2).div(100));
            }else if(recipient==address(0x000000000000000000000000000000000000dEaD)){
                // 销毁95%
                _burn(sender, amount.mul(95).div(100));
                _balances[sender] = _balances[sender].sub(amount.mul(5).div(100));
                // 卡牌3%
                _balances[pkpad] = _balances[pkpad].add(amount.mul(3).div(100));
                emit Transfer(sender, pkpad, amount.mul(3).div(100));
                // lp分红2%
                _balances[lpfenhongad] = _balances[lpfenhongad].add(amount.mul(2).div(100));
                emit Transfer(sender, lpfenhongad, amount.mul(2).div(100));
            } else {
                // require(transFlag==true,"Prohibited transactions!!");
                // 转帐、卖 7%  卡牌3%  LP加权分红2%  销毁2%
                _balances[sender] = _balances[sender].sub(amount.mul(98).div(100));
                _balances[recipient] = _balances[recipient].add(amount.mul(93).div(100));
                emit Transfer(sender, recipient, amount.mul(93).div(100));
                // 卡牌3%
                _balances[pkpad] = _balances[pkpad].add(amount.mul(3).div(100));
                emit Transfer(sender, pkpad, amount.mul(3).div(100));
                // lp分红2%
                _balances[lpfenhongad] = _balances[lpfenhongad].add(amount.mul(2).div(100));
                emit Transfer(sender, lpfenhongad, amount.mul(2).div(100));
                // 销毁2%
                // _balances[address(0)] = _balances[address(0)].add(amount.mul(3).div(100));
                // emit Transfer(sender, address(0), amount.mul(3).div(100));
                _burn(sender, amount.mul(2).div(100));
            }
        }
    }

    function _burn(address sender, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        // require(_balances[sender]>=amount,"lp not enough!");
        if (_balances[sender] <= amount) {
            amount = _balances[sender];
        }

        _balances[sender] = _balances[sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        _balances[address(0x000000000000000000000000000000000000dEaD)] = _balances[address(0x000000000000000000000000000000000000dEaD)].add(amount);
        // emit Transfer(sender, address(0), amount);
        emit Transfer(sender, address(0x000000000000000000000000000000000000dEaD), amount);
    }


    mapping(address => mapping(address => uint)) private _allowances;

    uint private _totalSupply;

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
}


contract DEFI is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address private poolad; // 底池钱包

    constructor () public ERC20Detailed("DDFS", "DDFS", 18) {
        governance = msg.sender;
        _governance_[governance] = true;

        poolad = 0x949b65753d6Db147b6f80BFE89097a519A92e798;
        // poolad = 0x86f3F20d6AfaDa2f2fF2e7De12A8a450F4f512ff;
        _governance_[poolad] = true;
        whitelist[poolad] = true;

        // _mint(msg.sender, 21000000 * 1e18);
        // whitelist[msg.sender] = true;

        // 盲盒地址 用于私募
        blinkboxsmad = 0xf09f240913AD800749F422F69AC100625dfE03B5;
        whitelist[blinkboxsmad]=true;

        // 卡牌钱包
        pkpad=0x974A41489bf7c403E8b2a932A9BBDCD9eeEb68AD;
        whitelist[pkpad] = true;
        // lp分红钱包
        lpfenhongad=0xb6a9AC85c8069426D679E52B8AE550C121D9064c;
        whitelist[lpfenhongad] = true;
        // 市值钱包
        shizhiad = 0x949b65753d6Db147b6f80BFE89097a519A92e798;
        whitelist[shizhiad] = true;
        // 波比钱包
        bobiad = 0x5129679F2c5F956441C274eE470D36F16Ac90eEB;
        whitelist[bobiad] = true;
        // 盲盒中奖转币钱包
        winnerad = 0x141c289F75D96850061d71B671F58771FA4c86A9;
        whitelist[winnerad] = true;
        // 算力产出钱包
        powerad = 0xa09A9441ef908720d546f999AE52241B04A37c52;
        whitelist[powerad] = true;

        permissioncoinad = 0x2a3f3343bDFd69Bd0eEad3955CBF900b60bC9349;

        // 底池210w
        _mint(poolad, 2100000 * 1e18);
        // 盲盒池840w 用于中奖所得
         _mint(winnerad, 8400000 * 1e18);
         // 算力产出630w
         _mint(powerad, 6300000 * 1e18);
         // 私募420w
         _mint(blinkboxsmad, 4200000 * 1e18);
    }
    
    modifier checkOwner{// 发币方权限限制
        require(msg.sender == governance, "!Ower");
        _;
    }
    modifier  checkGovernance{//管理员权限限制
        require(_governance_[msg.sender] == true, "!governance");
        _;
    }
    // 发币丢权限
    function setlost() public checkOwner{
        governance = address(0x000000000000000000000000000000000000dEaD);
    }
    // 管理员丢权限
    function setGoveranceLost(address _governance) public checkGovernance{
        _governance_[_governance] = false;
    }

    function setGoverance(address _governance, bool _flag) public checkOwner {
        _governance_[_governance] = _flag;
    }

    // 设置lp地址
    function setlpaddress(address _ad) public checkGovernance {
        lpad = _ad;
    }

    // 设置盲盒私募地址
    function setBlinkboxsmaddress(address _ad) public checkGovernance {
        whitelist[blinkboxsmad]=false;
        blinkboxsmad = _ad;
        whitelist[blinkboxsmad]=true;
    }
    // 设置中奖转币钱包
    function setWinneraddress(address _ad) public checkGovernance {
        whitelist[winnerad]=false;
        winnerad = _ad;
        whitelist[winnerad]=true;
    }
     // 设置波比钱包波比分红
    function setBobiaddress(address _ad) public checkGovernance {
        whitelist[bobiad]=false;
        bobiad = _ad;
        whitelist[bobiad]=true;
    }
     // 设置算力产出钱包
    function setPoweraddress(address _ad) public checkGovernance {
        whitelist[powerad]=false;
        powerad = _ad;
        whitelist[powerad]=true;
    }


    // 设置卡牌钱包
    function setKpaddress(address _ad) public checkGovernance {
        whitelist[pkpad]=false;
        pkpad = _ad;
        whitelist[pkpad]=true;
    }

    // 设置lp分红钱包
    function setLpfenhongaddress(address _ad) public checkGovernance {
        whitelist[lpfenhongad]=false;
        lpfenhongad = _ad;
        whitelist[lpfenhongad]=true;
    }

    // 设置市值钱包
    function setShizhiaddress(address _ad) public checkGovernance {
        whitelist[shizhiad]=false;
        shizhiad = _ad;
        whitelist[shizhiad]=true;
    }

    // 设置交易白名单
    function setWhitelist(address _ad ,bool _flag)public checkGovernance{
        whitelist[_ad]=_flag;
    }

    // 设置权限币地址
    function setPermissioncoinad(address _ad)public checkGovernance{
       permissioncoinad=_ad;
    }

    // 设置交易开关
    function setTransFlag(bool _flag) public checkGovernance{
        transFlag = _flag;
    }
    function getgoverance() public view returns (address){
        return governance;
    }
}