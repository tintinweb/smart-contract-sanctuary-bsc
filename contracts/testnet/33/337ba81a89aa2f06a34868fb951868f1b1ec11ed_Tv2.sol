// SPDX-License-Identifier: MIT

  
pragma solidity ^0.8.3;
contract Tv2   {
    string  public name ;
    string  public symbol  ;
    uint256 public totalSupply; // 1 million tokens
    uint8   public decimals ;
    address private _owner;
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public whitelist;

   
    //  function initialize() external{ 
    //       balanceOf[msg.sender] = totalSupply; 
    //       name = "DApp Token";
    //       symbol = "DAPP";
    //       totalSupply = 1000000000000000000000000; // 1 million tokens
    //       decimals = 18;
    //       _owner = _msgSender();
    
    //  }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    //     require(_value <= balanceOf[_from]);
    //     require(_value <= allowance[_from][msg.sender]);
    //     balanceOf[_from] -= _value;
    //     balanceOf[_to] += _value;
    //     allowance[_from][msg.sender] -= _value;
    //     emit Transfer(_from, _to, _value);
    //     return true;
    // }

      function addWhitelist(address _newEntry) external onlyOwner {
    whitelist[_newEntry] = true;
  }
    
  function removeWhitelist(address _newEntry) external onlyOwner {
    require(whitelist[_newEntry], "Previous not in whitelist");
    whitelist[_newEntry] = false;
  }
  function verifyUser(address _whitelistedAddress) public view returns(bool) {
    bool userIsWhitelisted = whitelist[_whitelistedAddress];
    return userIsWhitelisted;
}
function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    // upgraded with these functions 
function f1() internal view virtual returns (uint) {
        return 1;
    }
    // upgraded with these functions 

    function f2() internal view virtual returns (uint) {
        return 2;
    }

  
modifier isWhitelisted() {
  require(whitelist[_msgSender()], "You need to be whitelisted");
  _;
}
   modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}