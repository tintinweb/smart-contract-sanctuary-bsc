/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT

/**


╭━━━┳╮╭╮╱╱╱╱╱╭━╮╭╮╱╭╮╱╱╱╭━━━╮╱╱╱╱╱╭━━━╮╱╱╱╱╱╱╱╭╮╭━╮╭━╮╱╱╭╮
┃╭━╮┃┃┃┃╱╱╱╱╱┃╭╯┃┃╱┃┃╱╱╱┃╭━╮┃╱╱╱╱╱╰╮╭╮┃╱╱╱╱╱╱╱┃┃┃┃╰╯┃┃╱╭╯╰╮
┃┃╱┃┃┃┃┃╱╭━━┳╯╰╮┃┃╱┃┣━━╮┃┃╱┃┣━┳━━╮╱┃┃┃┣━━┳━━┳━╯┃┃╭╮╭╮┣━┻╮╭╋━━┳╮╭┳━━┳━┳━━┳━━╮
┃╰━╯┃┃┃┃╱┃╭╮┣╮╭╯┃┃╱┃┃━━┫┃╰━╯┃╭┫┃━┫╱┃┃┃┃┃━┫╭╮┃╭╮┃┃┃┃┃┃┃┃━┫┃┃╭╮┃╰╯┃┃━┫╭┫━━┫┃━┫
┃╭━╮┃╰┫╰╮┃╰╯┃┃┃╱┃╰━╯┣━━┃┃╭━╮┃┃┃┃━┫╭╯╰╯┃┃━┫╭╮┃╰╯┃┃┃┃┃┃┃┃━┫╰┫╭╮┣╮╭┫┃━┫┃┣━━┃┃━┫
╰╯╱╰┻━┻━╯╰━━╯╰╯╱╰━━━┻━━╯╰╯╱╰┻╯╰━━╯╰━━━┻━━┻╯╰┻━━╯╰╯╰╯╰┻━━┻━┻╯╰╯╰╯╰━━┻╯╰━━┻━━╯


Official Website: https://allofusaredead.net

Telegram: https://t.me/AllofUsAreDeadGameFi

Twitter: https://twitter.com/allusdead

Reddit: https://www.reddit.com/user/ALLofUSareDEAD

*/

pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function newOwner() public view virtual returns (address) {
        return _newOwner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address transferOwner) public onlyOwner {
        require(transferOwner != newOwner());
        _newOwner = transferOwner;
    }

    function acceptOwnership() virtual public {
        require(msg.sender == newOwner(), "Ownable: caller is not the new owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }
}

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

pragma solidity ^0.8.0;

contract AllofUsAreDeadBEP20 is IBEP20, Ownable {

    string constant public name = "AllofUsAreDead Metaverse";
    string constant public symbol = "DEADmeta";
    uint8 constant public decimals = 18;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    bool private _burningAllowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event UpdateBurningAllowance(address user, bool burningAllowance);

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function burningAllowance() external view returns (bool) {
        return _burningAllowance;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint allowed = _allowances[sender][msg.sender];
        require(allowed >= amount, "AllofUsAreDeadBEP20: transfer amount exceeds allowance");

        if (allowed < type(uint).max) {
            unchecked {
                _approve(sender, msg.sender, allowed - amount);
            }
        }

        _transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) external {
        require(_burningAllowance, "AllofUsAreDeadBEP20: burning is not allowed");
        uint256 accountBalance = _balances[msg.sender];
        require(accountBalance >= amount, "AllofUsAreDeadBEP20: burn amount exceeds balance");

        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "AllofUsAreDeadBEP20: transfer from the zero address");
        require(recipient != address(0), "AllofUsAreDeadBEP20: transfer to the zero address");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "AllofUsAreDeadBEP20: approve from the zero address");
        require(spender != address(0), "AllofUsAreDeadBEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(amount > 0, "AllofUsAreDeadBEP20: Zero mint amount");

        _balances[account] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }

    function mint(uint256 amount) external onlyOwner {
        _mint(msg.sender, amount);
    }

    function mintTo(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "AllofUsAreDeadBEP20: mint to the zero address");
        _mint(account, amount);
    }

    function updateBurningAllowance(bool isAllowed) external onlyOwner {
        _burningAllowance = isAllowed;
        emit UpdateBurningAllowance(msg.sender, isAllowed);
    }
}