/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    address private _manager;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    constructor() {
        _transferOwnership(_msgSender());
        _transferManagement(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    modifier onlyManager() {
        _checkManager();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function manager() public view virtual returns (address) {
        return _manager;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function _checkManager() internal view virtual {
        require(manager() == _msgSender(), "Ownable: caller is not the manager");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferManagement(address newManager) public virtual onlyOwner {
        require(newManager != address(0), "Ownable: new manager is the zero address");
        _transferManagement(newManager);
    }
    function _transferManagement(address newManager) internal virtual {
        address oldManager = _manager;
        _manager = newManager;
        emit ManagementTransferred(oldManager, newManager);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function owner() external view returns (address);
    function name() external view returns (string calldata);
    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @title SwishFish Guild's Contract
 * @author HeisenDev
 */
contract SwishFishGuilds is Ownable {
    using SafeMath for uint256;
    uint256 guild_program_tax = 10;
    uint256 guild_program_price = 0.5 ether;
    uint256 total_ether = 0;

    struct Guild {
        string name;
        address payable creator_address;
        uint256 tax_fee_creator;
        uint256 tax_fee_community;
        uint256 price;
        uint256 level;
        uint256 bank;
        uint256 members;
        address payable [] guild_member_address;
        bool isGuild;
    }

    mapping(string => Guild) public guilds;
    mapping(address => bool) public guild_member;
    mapping(address => uint256) public guild_member_level_join;
    mapping(address => string) public guild_name_member;
    mapping(address => bool) public guild_owner;
    string[] public guild_name;
    
    event Deposit(address indexed sender, uint amount);
    event GuildPrice(address indexed sender, uint amount);
    event GuildCreated(string indexed name, address indexed creator, uint tax_fee_creator, uint tax_fee_community, uint price);
    event GuildPayment(string indexed name, address indexed creator, uint creator_amount, uint community_amount, uint members);
    event JoinGuild(string indexed name, address indexed member, uint price, uint bank);
    event LeaveGuild(string indexed name, address indexed member);

    constructor() {
    }


    /// @dev Fallback function allows to deposit ether.
    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(_msgSender(), msg.value);
        } else {

        }
    }

    modifier notGuildOwner() {
        require(!guild_owner[_msgSender()], "GuildProgram: member in Guild");
        _;
    }
    modifier notGuildMember() {
        require(!guild_member[_msgSender()], "GuildProgram: owner in Guild");
        _;
    }
    modifier isGuildMember() {
        require(guild_member[_msgSender()], "GuildProgram: member isn't in a Guild");
        _;
    }

    modifier isGuildCreated(string memory guild_name_) {
        require(guilds[guild_name_].isGuild, "GuildProgram: Guild not exists");
        _;
    }

    modifier isNotGuildCreated(string memory guild_name_) {
        require(!guilds[guild_name_].isGuild, "GuildProgram: Guild already exists");
        _;
    }

    function total_guilds() public view virtual returns (uint) {
        return guild_name.length;
    }
    function getMembers(string memory guild_name_) public view virtual returns  (address payable[] memory ) {
        Guild storage _guild = guilds[guild_name_];
        return _guild.guild_member_address;
    }
    function getGuilds() public view virtual returns  (string[] memory ) {
        return guild_name;
    }

    function createGuild(
        string memory name_,
        uint256 tax_fee_creator_,
        uint256 tax_fee_community_,
        uint256 price_
    ) external payable isNotGuildCreated(name_) notGuildOwner {
        require((tax_fee_creator_ + tax_fee_community_) <= 100, "New Guild: commissions must be less than 100 percent");
        require(tax_fee_creator_  <= 10, "New Guild: commissions must be less than 100 percent");
        require(msg.value >= guild_program_price, "New Guild: commissions must be less than 100 percent");
        require(price_ >= 0.03 ether, "New Guild: Price too low, required at least 0.03 Ether");
        uint256 amount = msg.value;
        (bool sent,) = manager().call{value: amount}("");
        require(sent, "GuildProgram: failed to send manager ETH");
        guilds[name_] = Guild({
        name: name_,
        creator_address: payable(_msgSender()),
        tax_fee_creator: tax_fee_creator_,
        tax_fee_community: tax_fee_community_,
        price: price_,
        level: 1,
        bank: 0,
        members: 0,
        guild_member_address: new address payable [](0),
        isGuild: true
        });
        guild_name.push(name_);
        guild_owner[_msgSender()] = true;
        guild_program_price = guild_program_price + 0.01 ether;
        emit GuildCreated(name_, _msgSender(), tax_fee_creator_, tax_fee_community_, price_);
    }

    function joinGuild(string memory guild_name_) external payable isGuildCreated(guild_name_) notGuildMember {
        Guild storage _guild = guilds[guild_name_];
        require(msg.value >= _guild.price, "GuildProgram: You need to send some ether");
        uint256 amount = msg.value;
        total_ether = amount.add(amount);
        uint256 _guild_program_amount = amount.mul(guild_program_tax).div(100);
        (bool sent,) = manager().call{value: _guild_program_amount}("");
        require(sent, "GuildProgram: failed to send manager ETH");
        uint256 _bank_amount = amount.sub(_guild_program_amount);
        _guild.bank = _guild.bank.add(_bank_amount); 
        _guild.members++;
        _guild.guild_member_address.push(payable(_msgSender()));
        guild_member[_msgSender()] = true;
        guild_name_member[_msgSender()] = guild_name_;
        guild_member_level_join[_msgSender()] = _guild.level;
        if (_guild.bank > guildExperience(_guild.level)) {
            guildPayment(guild_name_);
        }
        emit JoinGuild( guild_name_, _msgSender(), msg.value, _guild.bank);
    }
    
    function guildExperience(uint256 level) internal pure returns (uint256) {
        return [500000000000000000, 1000000000000000000, 2000000000000000000, 3000000000000000000, 4000000000000000000, 5000000000000000000, 6000000000000000000, 7000000000000000000][level - 1];
    }
    function leaveGuild(string memory guild_name_) external isGuildMember {
        Guild storage _guild = guilds[guild_name_];
        uint256 _members = _guild.guild_member_address.length;
        for (uint i=0; i < _members; i++) {
            if ( _guild.guild_member_address[i] == _msgSender()) {    
                _guild.guild_member_address[i] = _guild.guild_member_address[_members-1];
                break;
            }
        }
        _guild.members--;
        _guild.guild_member_address.pop();
        guild_member[_msgSender()] = false;
        guild_name_member[_msgSender()] = "";
        guild_member_level_join[_msgSender()] = 0;
        emit LeaveGuild(guild_name_, _msgSender());
    }
    
    function guildPayment(string memory guild_name_) internal {
        Guild storage _guild = guilds[guild_name_];
        uint256 _payment_amount = _guild.bank;
        uint256 _community_amount = _payment_amount.mul(_guild.tax_fee_community).div(100);
        uint256 _members = 0;
        for (uint i=0; i < _guild.guild_member_address.length; i++) {
            if (guild_member_level_join[_guild.guild_member_address[i]] < _guild.level) {
                _members++;
            }
        }
        bool sent;
        uint256 _member_amount_sent = 0;
        uint256 _creator_amount = 0;
        if (_members > 0 ) {
            uint256 _member_amount = _community_amount.div(_members);
            for (uint i=0; i < _guild.guild_member_address.length; i++) {
                if (guild_member_level_join[_guild.guild_member_address[i]] < _guild.level) {
                    (sent,) = _guild.guild_member_address[i].call{value: _member_amount}("");
                    require(sent, "GuildProgram: failed to send community ETH");
                    _member_amount_sent = _member_amount_sent.add(_member_amount);
                }
            }
            _creator_amount = _payment_amount.sub(_member_amount_sent);
        } else {
            _creator_amount = _payment_amount;
            _community_amount = 0;
        }
        (sent,) = _guild.creator_address.call{value : _creator_amount}("");
        require(sent, "GuildProgram: Failed to send creator ETH");
        if (_guild.level < 8) {
            _guild.level++;
        }
        _guild.bank = 0;
        emit GuildPayment(guild_name_, _msgSender(), _creator_amount, _community_amount, _members);
    }

    function guildPrice(uint256 price_) external onlyOwner {
        require(price_ >= 0.5 ether, "GuildProgram: price too low, required at least 0.5 ether");
        guild_program_price = price_;
        emit GuildPrice(_msgSender(), price_);
    }
}