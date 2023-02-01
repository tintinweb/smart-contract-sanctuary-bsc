/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity  ^0.8.9;

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}
interface iburn_token {
    function power(address owner) external view returns (uint256);
    function invite(address owner) external view returns (address);
    function last_miner(address owner) external view returns (uint256);
}

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
}

contract iFly is SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals = 3;
    uint public epoch_base = 86400;
    uint public burn_no = 4;
    uint public epoch = 86400;
    uint public start_time;
    uint256 public totalSupply;
    uint256 public totalPower;
    uint256 public totalUsersAmount;
    address payable public owner;
    bool public is_airdrop = true;
    bool public is_upgrade = false;
    bool public is_mint = false;

    uint public anti_bot = 1000000;
    address public requireToken = 0x73b3B1b2cACAB92963144277458E2E9851517022;
    address public daoAddress;
    uint256 public ethBurn = 1 * 10 ** 15;

    uint public burnTokenAmount = 2000;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public TokenBalanceOf;
    mapping (address => address) public invite;
    mapping (address => uint256) public power;
    mapping (address => uint256) public last_miner;
    mapping (address => uint256) public last_day;
    mapping (address => uint256) public freezeOf;
    mapping (address => uint256) public inviteCount;
    mapping (address => uint256) public rewardCount;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    event Freeze(address indexed from, uint256 value);

    event Unfreeze(address indexed from, uint256 value);

    event Minted(
        address indexed operator,
        address indexed to,
        uint256 amount
    );

    event  Deposit(address indexed dst,address token, uint wad);
    event  Withdrawal(address indexed src,address token, uint wad);

    constructor(
        string memory tokenName,
        string memory tokenSymbol
        ) {
        totalSupply = 1000000000;
        name = tokenName;
        symbol = tokenSymbol;
        owner = payable(msg.sender);
        daoAddress = owner;
        epoch_base = 86400;
        epoch = epoch_base;
        balanceOf[owner] = 1000000000;
    }

    receive() payable external {
    }

    function withdraw(uint amount) public {
        require(msg.sender == owner);
        owner.transfer(amount);
    }

    function depositToken(address token,uint256 amount) public {
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        TokenBalanceOf[msg.sender][token] += amount;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
		require(_value > 0);
        require(msg.sender != _to);
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(!((_value != 0) && (allowance[msg.sender][_spender] != 0)));

		require(_value >= 0);
        allowance[msg.sender][_spender] = _value;
        return true;
    }


    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)  {
        if (_to == address(0)) revert();                             // Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) revert();
        require(_from != _to);

        if (balanceOf[_from] < _value) revert();              // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  // Check for overflows
        if (_value > allowance[_from][msg.sender]) revert();  // Check allowance

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                        // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                          // Add the same to the recipient
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function airdrop() public payable{
        require(power[msg.sender] == 0);
        require(is_airdrop);

        require(msg.value >= ethBurn);
        payable(daoAddress).transfer(msg.value);

        power[msg.sender] = 3 * 1e3;
        totalPower += 3 *  1e3;
        totalUsersAmount++;
    }

    function Daydrop() public payable {
        require(block.timestamp - last_day[msg.sender] >= 86400);
        require(power[msg.sender] > 0);

        require(msg.value >= ethBurn);
        payable(daoAddress).transfer(msg.value);

        power[msg.sender] += 1 * 1e3;
        totalPower += 1 *  1e3;
		last_day[msg.sender] = block.timestamp;
    }

    function upgrade() public{
        require(power[msg.sender] == 0);
        require(is_upgrade);
        uint256 bt_power = iburn_token(0x000000000000000000000000000000000000dEaD).power(msg.sender);
        if(bt_power > 90e3)
        {
            power[msg.sender] = bt_power;
            totalPower += bt_power;
            totalUsersAmount++;
        }

        uint256 bt_last_miner = iburn_token(0x000000000000000000000000000000000000dEaD).last_miner(msg.sender);
        if(bt_last_miner > 0)
        {
            last_miner[msg.sender] = bt_last_miner;
        }

        address bt_invite  = iburn_token(0x000000000000000000000000000000000000dEaD).invite(msg.sender);
        if(bt_invite != address(0))
        {
            invite[msg.sender] = bt_invite;
            inviteCount[bt_invite] += 1;
        }
    }

    function stop_upgrade() public{
        require(msg.sender == owner);
        require(is_upgrade);
        is_upgrade = false;
    }


    function burn(uint256 _value) public returns (bool success)  {
        require(balanceOf[msg.sender] >= _value);         // Check if the sender has enough
		require(_value > 0);

        if (burnTokenAmount > 0) {
            require(TokenBalanceOf[msg.sender][requireToken] >= burnTokenAmount * _value,"token insufficient");
            TokenBalanceOf[msg.sender][requireToken] -= burnTokenAmount * _value;
            TransferHelper.safeTransfer(requireToken,address(0x000000000000000000000000000000000000dEaD), burnTokenAmount * _value);
        }

        if (power[msg.sender] > 0 && block.timestamp - last_miner[msg.sender] >= epoch){
            if(power[msg.sender] < 500 * 1e3 && TokenBalanceOf[msg.sender][requireToken] >= anti_bot) {
                mint();
            } else if (power[msg.sender] >= 500 * 1e3){
                mint();
            }
        }

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                   // Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply,_value);                             // Updates totalSupply
        if(power[msg.sender] == 0)
            totalUsersAmount++;
        power[msg.sender] += _value * burn_no;
        emit Transfer(msg.sender,address(0),_value);
        totalPower += _value * burn_no;
        reward_upline(_value);
        return true;
    }

    function reward_upline(uint256 _value) private returns (bool success){
        if(invite[msg.sender] != address(0))
        {
            address invite1 = invite[msg.sender];

            if(power[invite1] == 0)
                return true;
            uint8 scale = 2;
            if(power[invite1] < 500 * 1e3)
            {
                scale = 2;
            }
            else if(power[invite1] < 5000 * 1e3)
            {
                scale = 4;
            }
            else if(power[invite1] < 10000 * 1e3)
            {
                scale = 5;
            }
            else if(power[invite1] < 20000 * 1e3)
            {
                scale = 6;
            }
            else if(power[invite1] < 40000 * 1e3)
            {
                scale = 7;
            }
            else if(power[invite1] >= 40000 * 1e3)
            {
                scale = 8;
            }
            uint256 reward = _value * scale / 100;
            if(power[invite1] < reward)
            {
                reward = power[invite1];
            }

            power[invite1] = power[invite1] + reward;
            totalPower = totalPower + reward;

            return true;
        }
        return true;
    }

	function freeze(uint256 _value) public returns (bool success)  {
        if (balanceOf[msg.sender] < _value) revert();         // Check if the sender has enough
		if (_value <= 0) revert();
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                   // Subtract from the sender
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                             // Updates totalSupply
        emit Freeze(msg.sender, _value);
        return true;
    }

	function unfreeze(uint256 _value) public returns (bool success) {
        if (freezeOf[msg.sender] < _value) revert();         // Check if the sender has enough
		if (_value <= 0) revert();
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                   // Subtract from the sender
		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }


    function setOwner(address payable new_owner) public {
        require(msg.sender == owner);
        owner = new_owner;
    }

    function setDao(address new_dao) public {
        require(msg.sender == owner);
        daoAddress = new_dao;
    }


    function setAirdrop() public{
        require(msg.sender == owner);
        is_airdrop = !is_airdrop;
    }

    function setAntiBot(uint _value) public{
        require(msg.sender == owner);
        anti_bot = _value;
    }

    function setBurnNo(uint _value) public{
        require(msg.sender == owner);
        burn_no = _value;
    }

    function setburnTokenAmount(uint _value) public{
        require(msg.sender == owner);
        burnTokenAmount = _value;
    }

    function startMint()public{
        require(msg.sender == owner);
        is_mint = true;
        start_time = block.timestamp;
    }


    function update_epoch() private returns (bool success){
        epoch =  epoch_base + (block.timestamp - start_time)/365;
        return true;
    }

    function registration(address invite_address) public returns (bool success){
        require(invite[msg.sender] == address(0));
        require(msg.sender != invite_address);
        invite[msg.sender] = invite_address;
        inviteCount[invite_address] += 1;
        return true;
    }

    function mint() public returns (bool success){
        update_epoch();
        require(is_mint,"not start mint");
        require(power[msg.sender] > 0); 
        require(block.timestamp - last_miner[msg.sender] >= epoch);
        uint8 scale = 10; 
        if(power[msg.sender] < 500 * 1e3)
        {
            scale = 10;
            require(TokenBalanceOf[msg.sender][requireToken] >= anti_bot,"token too low");
        }
        else if(power[msg.sender] < 5000* 1e3)
        {
            scale = 20;
        }
        else if(power[msg.sender] < 10000 * 1e3)
        {
            scale = 30;
        }
        else if(power[msg.sender] < 20000 * 1e3)
        {
            scale = 40;
        }
        else if(power[msg.sender] < 40000 * 1e3)
        {
            scale = 50;
        }
        else if(power[msg.sender] > 40000 * 1e3)
        {
            scale = 60;
        }

        uint miner_days=(block.timestamp - last_miner[msg.sender])/epoch;

        if(miner_days > 5)
        {
            miner_days = 5;
        }

        if(last_miner[msg.sender] == 0)
        {
            miner_days = 1;
        }

        if(miner_days > 1 && power[msg.sender] < 500 * 1e3)
        {
            miner_days = 1;
        }

        uint256 reward = power[msg.sender] * miner_days * scale / 10000;
        power[msg.sender] = power[msg.sender] - reward;
        totalPower = totalPower - reward;
        balanceOf[msg.sender] =  balanceOf[msg.sender] + reward;
        totalSupply = totalSupply + reward;
        last_miner[msg.sender] = block.timestamp;
        emit Transfer(address(0), msg.sender, reward);
        return true;
    }
}