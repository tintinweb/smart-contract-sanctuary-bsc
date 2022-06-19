/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.9.0;

contract orbitainContract {

    event Transfer(address indexed from, address indexed to, uint256 amount);

    string public name = "Orbitain";//token name public view
    string public symbol = "ORBT";//token symbol public view
    address payable owner = payable(msg.sender);

    mapping(address => uint256) private balances;
    mapping(uint => uint) private dailyTotals;
    mapping(uint => mapping(address => uint)) private userContribute;
    mapping(uint => mapping(address => bool)) private claimed;
    mapping (address => string) private keys;

    //function decimals.
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    uint256 public totalSupply = 1000000000 * 10 ** decimals();
    uint256 public totalMinted;
    uint256 public totalBurnt;
    uint public openTime = 1655619600;
    uint public startTime = 1655623200;
    uint public numberOfDays = 200;
    uint public createFirstDay = 100000000 * 10 ** decimals();
    uint public createPerDay = 4000000 * 10 ** decimals();
    uint private startDay;

    event LogContribution (uint window, address user, uint amount);
    event LogClaim (uint window, address user, uint amount);
    event LogRegister (address user, string publicKey, uint amount);
    
    constructor()  {
        _mint(owner, 100000000 * 10 ** decimals());//mint 100 million token to owner address
    }

    //Owner withdrawel BNB address code start

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function Withdraw(uint256 amount) public onlyOwner{
        owner.transfer(amount);
    }

    //Owner withdrawel BNB address code end


    //Time based function for token distribution code start   

    function time() internal returns (uint){
        return block.timestamp;
    }

    function today() internal returns (uint){
        return dayFor(time());
    }

    function dayFor (uint timeStamp) internal returns (uint){
        return timeStamp < startTime ? 0 : (timeStamp - startTime) / 59 minutes + 1;
    }

    function createOnDay(uint day) internal returns (uint) {
        return day == 0 ? createFirstDay : createPerDay;
    }

    //Time based function for token distribution code ends.

    //Contribution and claming functions code starts

    function contribute(uint slotNumber) public payable {
        require(msg.value >= 0.01 ether, "Minimum Contribution is 0.01 ETH");
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
            return;
        }
        
        uint userTotal = userContribute[slotNumber][msg.sender];
        uint price = createOnDay(slotNumber) / dailyTotals[slotNumber];
        uint reward = price * userTotal;

        claimed[slotNumber][msg.sender]=true;
        _mint(msg.sender, reward);

        emit LogClaim(slotNumber, msg.sender, reward);

    }

    //Contribution and claming functions code ends.

    function setRegDate(uint16 day) public onlyOwner{
        startDay = day;
    }

    function register(uint256 amount, string memory publicKey) public {
        require(today() <= startDay, "The Registration not yet started");
        require(bytes(publicKey).length <= 64);

        _burn(msg.sender, amount);
        keys[msg.sender] = publicKey;
        emit LogRegister(msg.sender, publicKey, amount);
    }

    //token minting function
    function _mint(address account, uint256 amount) internal virtual {
        require (totalMinted <= totalSupply, "ORBT: Reached Totalsupply");
        require (account != address(0), "ORBT: mint to zero account");

        _beforeTokenTransfer(address(0), account, amount);
        totalMinted += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    //token burning function
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ORBT: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ORBT: burn amount exceeds balance");
        unchecked {
            balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;
        totalBurnt += amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    //Orbitain call function code starts

    function balance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function ownerAddress () public view returns(address){
        return owner;
    }

    function balanceOf (address account) public view returns(uint256){
        return balances[account];
    }

    function totalDailyContribution() public view returns(uint[351] memory result){
        for (uint i = 0; i < 201; i++){
            result[i] = dailyTotals[i];
        }
    }

    function userContributed(address user) public view returns (uint[351] memory result) {
        for (uint i = 0; i < 201; i++) {
            result[i] = userContribute[i][user];
        }
    }

    function userClaims(address user) public view returns (bool[351] memory result) {
        for (uint i = 0; i < 201; i++) {
            result[i] = claimed[i] [user];
        }
    }

    //Orbitain call function code ends

    //Orbitain Token transfer process functions starts

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
        require(from != address(0), "ORBT: transfer from the zero address");
        require(to != address(0), "ORBT: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = balances[from];
        require(fromBalance >= amount, "ORBT: transfer amount exceeds balance");
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

    //Orbitain Token transfer process functions ends.
}