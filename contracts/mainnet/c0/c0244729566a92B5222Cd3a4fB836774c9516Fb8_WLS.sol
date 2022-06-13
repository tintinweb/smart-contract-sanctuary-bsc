/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

//SPDX-License-Identifier:UNLICENSED
pragma solidity >=0.7.0 <0.9.0;


contract WLS
{
    mapping (address => uint256) private _balances;
    mapping (uint256 => bool) private _usedNonces;
    mapping(address => mapping(address => uint256)) private _allowances;


    string private _name = "Win Live Star";
    string private _symbol = "WLS";

    //address walletSupply = msg.sender; //commented so we can use an offline wallet
    address walletSupply = 0xD7ee9Df29C5d9e3829369BAE16625f094f6F4B69;

    address walletCashRegister = 0xce7C362528a1E87d4078dcDB928ef5236195d443; //Used as a layer of security

    address walletTeam = 0xBf2F88fA393f3456AC04917Af73f9701ec79CD97; //Unlock after 365 days unless we increase it

    address walletBurn = 0xA65e6aAA9B40F32D1D686b04013c43a4ad26f8FF; //Locked forever

    uint private _decimals = 18;

    uint private _supply = 100000000;

    uint private teamWalletsUnlockTime = block.timestamp + (86400 * 365); //Team wallet is locked for the first 365 days

    bool private maintenanceMode = false;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor()  {

        uint supply = _supply;

        uint teamMemberShare = 500000;

        _balances[walletTeam] = teamMemberShare * (10 ** _decimals);
        supply = supply - teamMemberShare;


        uint cashRegisterShare = 50000;
        _balances[walletCashRegister] = cashRegisterShare * (10 ** _decimals);

        supply = supply - cashRegisterShare;


        _balances[walletSupply] = supply * (10 ** _decimals);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint) {
        return _decimals;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _supply;
    }

    function contractWalletSupply() public view virtual returns (uint256) {
        return _balances[walletSupply];
    }

    function cashRegisterWalletSupply() public view virtual returns (uint256) {
        return _balances[walletCashRegister];
    }

    function teamWalletSupply() public view virtual returns (uint256) {
        return _balances[walletTeam];
    }

    function burnWalletSupply() public view virtual returns (uint256) {
        return _balances[walletBurn];
    }

    function balanceOf(address user) public view returns (uint)
    {
        return _balances[user];
    }

    function transfer(address to, uint value) public returns (bool)
    {
        require(!maintenanceMode, "Token maintenance");
        require(balanceOf(msg.sender)>=value, "Insufficient funds");


        if(msg.sender == walletTeam) {

            require(block.timestamp > teamWalletsUnlockTime, "Team wallets are still locked");
        }

        require(msg.sender != walletBurn, "Burn wallet forever locked");

        _balances[to]+=value;
        _balances[msg.sender]-=value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    function maintenance(bool value) public returns (bool)
    {

        require(walletSupply == msg.sender, "Contract owner only");

        maintenanceMode = value;

        return true;
    }


    function getTeamUnlockTime() public view returns (uint)
    {
        return teamWalletsUnlockTime;
    }

    function increaseTeamLockTime(uint value) public returns (bool)
    {

        require(walletSupply == msg.sender, "Contract owner only");

        teamWalletsUnlockTime += value;

        return true;
    }

    function claim(uint256 amount, uint256 nonce, bytes memory signature) external returns (bool) {

        require(!maintenanceMode, "Token maintenance");
        require(!_usedNonces[nonce], "Duplicate transaction");
        require(block.timestamp < nonce, "Time limit expiration");

        _usedNonces[nonce] = true;

        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

        require(recoverSigner(message, signature) == walletCashRegister, "Wrong hash");

        require(_balances[walletCashRegister] > amount, "Not enough tokens available");

        _balances[walletCashRegister]-=amount;
        _balances[msg.sender]+=amount;

        emit Transfer(walletCashRegister, msg.sender, amount);

        return true;
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }





    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        require(!maintenanceMode, "Token maintenance");

        if(msg.sender == walletTeam) {
            require(block.timestamp > teamWalletsUnlockTime, "Team wallets are still locked");
        }

        require(msg.sender != walletBurn, "Burn wallet forever locked");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {

            require(!maintenanceMode, "Token maintenance");

            if(msg.sender == walletTeam) {
                require(block.timestamp > teamWalletsUnlockTime, "Team wallets are still locked");
            }

            require(msg.sender != walletBurn, "Burn wallet forever locked");

            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}