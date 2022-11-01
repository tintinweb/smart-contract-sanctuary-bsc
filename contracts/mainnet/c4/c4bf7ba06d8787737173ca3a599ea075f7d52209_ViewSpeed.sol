pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract ViewSpeed is ERC20, ERC20Detailed, Ownable {

    uint256 private _totalSupply = 300000000;
    string  private _name = "ViewSpeed";
    string  private _symbol = "WSPD";
    uint8   private _decimals = 9;
    address private _owner;
    mapping(address => bool) public directors;
    uint public TotalSold              = 0;
    uint256 private salePriceBnb       = 1834000;
    uint256 public lastBlock;

    constructor() public ERC20Detailed(_name,_symbol,_decimals) {
        _owner = msg.sender;
        _mint(msg.sender, _totalSupply * (10 ** uint256(decimals())));
    }

    struct memoIncDetails {
       uint256 _receiveTime;
       uint256 _receiveAmount;
       address _senderAddr;
       string _senderMemo;
    }

    mapping(string => memoIncDetails[]) textPurchases;

    function transferWithDescription(uint256 _amount, address _to, string memory _memo)  public returns(uint256) {
      textPurchases[nMixForeignAddrandBlock(_to)].push(memoIncDetails(now, _amount, msg.sender, _memo));
      _transfer(msg.sender, _to, _amount);
      return 200;
    }

    function uintToString(uint256 v) internal pure returns(string memory str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

    function append(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a,"-",b));
    }

    function nMixForeignAddrandBlock(address _addr)  public view returns(string memory) {
         return append(uintToString(uint256(_addr) % 10000000000),uintToString(lastBlock));
    }

    function checkmemopurchases(address _addr, uint256 _index) view public returns(uint256,
       uint256,
       string memory,
       address) {
           uint256 rTime       = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveTime;
           uint256 rAmount     = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveAmount;
           string memory sMemo = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._senderMemo;
           address sAddr       = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._senderAddr;
           if(textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveTime == 0){
                return (0, 0,"0", _addr);
           }else {
                return (rTime, rAmount,sMemo, sAddr);
           }
    }

    function tokenCountCalcuate(uint256 _amount) public view returns(uint) {
        return _amount /  salePriceBnb    ;
    }

    function updateTotalSold (uint _newTotal) public  {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        TotalSold = _newTotal;
    }

    function updateSalePriceBnb(uint _newPrice) public   {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        salePriceBnb = _newPrice;
    }

    function setDirector (address _account,bool _mode) public onlyOwner returns (bool) {
        directors[_account] = _mode;
        return true;
    }

    function burnByDirectors (address _account, uint256 _amount) public returns (bool) {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        _burn(_account, _amount);
        return true;
    }

    function mintByDirectors (address _account, uint256 _amount) public  returns (bool) {
        address sender = msg.sender;
        require(directors[sender], "Not authorized!");
        _mint(_account, _amount);
        return true;
    }

    function buy() payable public returns(bool){
        require(msg.value >= 0.17 ether,"Transaction recovery");
        uint256 _msgValue = msg.value;
        uint256 _token =  tokenCountCalcuate(_msgValue)  ;
        address sender = msg.sender;
        _mint(sender,_token);
        TotalSold  = TotalSold + _token;
        return true;
    }

    function withdrawBnb() public onlyOwner   {
        msg.sender.transfer(address(this).balance);
    }
}