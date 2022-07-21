/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

contract orbitaintoken {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    string constant public name = "Orbitain";//token name public view
    string constant public symbol = "RBT";//token symbol public view
    address payable owner = payable(msg.sender);

    mapping(address => uint256) private balances;
    mapping(uint => uint) private dailyTotals;
    mapping(uint => mapping(address => uint)) private userContribute;
    mapping(uint => mapping(address => bool)) private claimed;
    mapping(address => mapping(string => uint)) private keys;

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    uint256 public totalSupply = 1000000000 * 10 ** decimals();
    uint256 public totalAirdroped;
    uint256 public totalMinted;
    uint256 public totalBurnt;
    uint public openTime = 1658337900;
    uint public startTime = 1658424300;
    uint public numberOfDays = 250;
    uint public createFirstDay = 100000000 * 10 ** decimals();
    uint public createPerDay = 2000000 * 10 ** decimals();
    uint private startDay;

    event LogContribution (uint window, address user, uint amount);
    event LogClaim (uint window, address user, uint amount);
    event LogRegister (address user, string key, uint amount);
    
    constructor()  {
        _mint(owner, 100000000 * 10 ** decimals());//mint 200 million token to owner address
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function Withdraw(uint256 amount) public onlyOwner{
        owner.transfer(amount);
    }
 

    function time() internal returns (uint){
        return block.timestamp;
    }

    function today() internal returns (uint){
        return dayFor(time());
    }

    function dayFor (uint timeStamp) internal returns (uint){
        return timeStamp < startTime ? 0 : (timeStamp - startTime) / 23 hours + 1;
    }

    function createOnDay(uint day) internal returns (uint) {
        return day == 0 ? createFirstDay : createPerDay;
    }


    function airdrop(address[] memory to, uint amount) public onlyOwner returns (bool){
        for(uint i = 0; i < to.length; i++){
            require(to[i] != address(0));
            totalAirdroped += amount;
            _mint(to[i], amount);
        }
        return true;
    }

    function contribute(uint slotNumber) public payable {
        require(msg.value >= 0.01 ether, "Minimum Contribution is 0.05 BNB");
        require(time() >= openTime, "The Contribution time is not open yet");
        require (today() <= numberOfDays, "All the Contribution slots are closed");

        userContribute[slotNumber][msg.sender] += msg.value;
        dailyTotals[slotNumber] += msg.value;
        emit LogContribution(slotNumber, msg.sender, msg.value);
    }

    function contributeNow() public payable{
        contribute(today());
    }

    receive () external payable{
        contributeNow();
    }

    function claimToken(uint slotNumber) public {
        require(today() > slotNumber, "You Can't claim your token when slots are open");

        if (claimed[slotNumber][msg.sender] || dailyTotals[slotNumber] == 0){
            return revert("You already claimed the token or You didn't contribute in this period");
        }
        
        uint userTotal = userContribute[slotNumber][msg.sender];
        uint price = createOnDay(slotNumber) / dailyTotals[slotNumber];
        uint reward = price * userTotal;

        claimed[slotNumber][msg.sender]=true;
        _mint(msg.sender, reward);

        emit LogClaim(slotNumber, msg.sender, reward);

    }


    function setRegDate(uint16 day) public onlyOwner{
        startDay = day;
    }

    function register(uint256 amount, string memory publicKey) public {
        require(today() <= startDay, "The Registration not yet started");
        require(bytes(publicKey).length <= 64);

        _burn(msg.sender, amount);
        keys[msg.sender][publicKey] = amount;
        emit LogRegister(msg.sender, publicKey, amount );        
    }

    function _mint(address account, uint256 amount) internal virtual {
        require (totalMinted <= totalSupply, "RBT: Reached Totalsupply");
        require (account != address(0), "RBT: mint to zero account");

        _beforeTokenTransfer(address(0), account, amount);
        totalMinted += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "RBT: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = balances[account];
        require(accountBalance != 0, "You Can't burn Zero Value Tokens");
        require(accountBalance >= amount, "RBT: burn amount exceeds balance");
        unchecked {
            balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;
        totalBurnt += amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }


    function balance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function ownerAddress () public view returns(address){
        return owner;
    }

    function balanceOf (address account) public view returns(uint256){
        return balances[account];
    }

    function totalDailyContribution() public view returns(uint[251] memory result){
        for (uint i = 0; i < 251; i++){
            result[i] = dailyTotals[i];
        }
    }

    function userContributed(address user) public view returns (uint[251] memory result) {
        for (uint i = 0; i < 251; i++) {
            result[i] = userContribute[i][user];
        }
    }

    function userClaims(address user) public view returns (bool[251] memory result) {
        for (uint i = 0; i < 251; i++) {
            result[i] = claimed[i] [user];
        }
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(amount <= balances[from]);

        _transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender]);

        address sender = msg.sender;
        _transfer(sender, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "RBT: transfer from the zero address");
        require(to != address(0), "RBT: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = balances[from];
        require(fromBalance >= amount, "RBT: transfer amount exceeds balance");
        unchecked {
            balances[from] = fromBalance - amount;
        }
        balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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