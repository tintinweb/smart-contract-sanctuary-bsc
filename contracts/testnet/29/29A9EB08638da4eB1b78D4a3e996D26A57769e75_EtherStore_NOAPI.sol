//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract EtherStore_NOAPI {
    address public implementation;
    address public admin;
    bytes32 private jobId;
    uint256 private fee;
    string public data;
    mapping(address => uint) public balances;
    mapping(address => bool) private _gws;
    address public owner;
    uint256 private price;
    string public roman;
    int256  public sum;
    event GWAddeded(address indexed account);

    constructor (){
        owner = msg.sender;
        price = 10;
        roman = "kaka";

    }

    modifier onlyGW {
        require(isGW(msg.sender), "Only GW can call");
      _;

   }
    modifier onlyOwner {
      require(msg.sender == owner,"not the owner");
      _;
   }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function addGW(address _newGW) external onlyOwner{
        _addGW(_newGW);

    }
    function _addGW(address _account) private{
        _gws[_account]= true;
        emit GWAddeded(_account);
    }
    function isGW(address _account) public view returns (bool) {
        return _gws[_account];
    }

    function deposit() public payable onlyGW {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public  onlyGW{
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    function update_price(uint256 _price) external
    {
        require(isGW(msg.sender), "Only GW can call");
        price =_price;

    }

    function change_name (string calldata _new_name) public

    {
    require(isGW(msg.sender), "Only GW can call");
    roman = _new_name;

    }

    function calc(int256 _num1, int256 _num2)  external  returns (int256)
    {
        if (isGW(msg.sender)){
        sum = _num1 + _num2;

    } return int256(sum);
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    function get_price() public view returns (uint256){
        return  (price);
    }


}