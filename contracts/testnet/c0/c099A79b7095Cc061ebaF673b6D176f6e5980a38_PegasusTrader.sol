/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity ^0.8.16;

contract PegasusTrader{

    mapping(address => uint256) private expiration;

    uint256 public value_renew;
    uint256 public total_renew = 0;

    event Renew(address cliente, uint256 timestamp);
    
    address payable public owner;
    constructor(){ 
        owner = payable(msg.sender); 
    }

    // OWNER FUNCS
    modifier onlyOwner() { require(msg.sender == owner); _; }
    function newOwner(address _newOwner) onlyOwner external { owner = payable(_newOwner); }
 
    // TRADER SETTINGS
    function changeExpiration(address _client, uint256 _timestamp) onlyOwner external{
        expiration[_client] = _timestamp;
    }
    function setValueRenew(uint256 _value) external onlyOwner{
        value_renew = _value;
    }

    function getTimeExpire(address _client) view external returns(uint256) { return expiration[_client]; }

    // RECOVERY
    function claimBeans() onlyOwner external{
        uint256 balance = address(this).balance;
        owner.transfer(balance);
    }

    function claimTokens(address _token) onlyOwner external{
        bytes memory data = abi.encodeWithSelector(0x70a08231, address(this));
        (, bytes memory received) = _token.staticcall(data);

        uint256 value = abi.decode(received, (uint256));

        data = abi.encodeWithSelector(0xa9059cbb, owner, value);
        (, received) = _token.call(data);
    }

    // SOCIAL MEDIA
    string public site     = "www.pegasussniper.com";
    string public telegram = "https://t.me/pegasusst";
    string public discord  = "https://discord.gg/EBxxjSDNWb";

    function setSocial(string memory _site, string memory _telegram, string memory _discord) onlyOwner external {
        site     = _site;
        telegram = _telegram;
        discord  = _discord;
    }

    // SIGNATURE
    function renewTime() payable external{
        require(msg.value == value_renew);
        owner.transfer(msg.value);

        expiration[msg.sender] = block.timestamp + 30 days;
        total_renew++;

        emit Renew(msg.sender, block.timestamp + 30 days);
    }
}