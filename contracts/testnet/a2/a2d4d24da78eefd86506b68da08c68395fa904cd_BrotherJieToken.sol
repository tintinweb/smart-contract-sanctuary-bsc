/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

pragma solidity ^0.8.16;

contract BrotherJieToken {
    string public constant name = "If I Had Known Earlier That Boys Would Be Sexually Assaulted Too";
    string public constant symbol = "JIE";
    uint8 public constant decimals = 6;

    // Total circulating supply
    uint256 private _totalSupply;

    // One "claim" call gives the sender (1 << _epoch) Tank Coins
    uint256 private _epoch;

    // After 8 rounds, rewards are halved
    uint256 private _round;

    // Total supply of Tank Coins that have been burnt
    uint256 private _totalBurned;

    // Total locked Tank Coins that will slowly be unlocked
    uint256 private _totalLocked;

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
 
    constructor(uint256 total) public {
        require(total >= 6 && total <= 255);
        _totalSupply = (1 << total);

        // Initialize balances
        // Sender has half of the total supply
        balances[msg.sender] = (1 << (total - 1));

        // 1/4 is temporarily locked at null address
        balances[address(0x0)] = (1 << (total - 2));

        // 1/4 is temporarily locked at 0x00000...01
        balances[address(0x01)] = (1 << (total - 2));
        _totalLocked = (1 << (total - 2));

        // In the 1st epoch, we distribute (1 / 8) / 8 of the total supply to "claim" sender
        _epoch = total - 3 - 3;
        require(_epoch >= 0);

        // _round was initially 0.
        // After 8 rounds, rewards are halved.
        _round = 0;
        _totalBurned = 0;
    }

	function add(uint256 x, uint256 y) private pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) private pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function giveTransferReward(address to, uint256 amount) private returns (bool success) {
        // For each transfer, we give 0.0005% of the locked amount, or 5% the transferred amount, to the sender as a reward
        uint256 transferReward = balances[address(0x01)] / 20000;
        if (transferReward > (amount / 20)) {
            transferReward = (amount / 20);
        }
        if (transferReward > 0) {
            balances[to] = add(balances[to], transferReward);
            balances[address(0x01)] = sub(balances[address(0x01)], transferReward);
            emit Transfer(address(0x01), to, transferReward);
            _totalLocked = sub(_totalLocked, transferReward);
        }
        return (transferReward > 0);
    }

    function transfer(address to, uint256 tokens) public returns (bool success) {
        if (to == address(0x01)) {
            return burn(tokens);
        }

        balances[msg.sender] = sub(balances[msg.sender], tokens);
        balances[to] = add(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);

        // For each transfer, we give 0.0005% of the locked amount to the sender as a reward
        giveTransferReward(msg.sender, tokens);

        return true;
    }
    
    function bulkTransfer(address[] calldata tokenOwners, uint256[] calldata tokens) public returns (bool success) {
        require(tokenOwners.length == tokens.length);
        uint256 transferred = 0;
        for (uint i = 0; i < tokenOwners.length; i++) {
            if (tokenOwners[i] == address(0x01)) {
                burn(tokens[i]);
                continue;
            }
            transferred += tokens[i];
            balances[msg.sender] = sub(balances[msg.sender], tokens[i]);
            balances[tokenOwners[i]] = add(balances[tokenOwners[i]], tokens[i]);
            emit Transfer(msg.sender, tokenOwners[i], tokens[i]);
        }
        // For each transfer, we give 0.0005% of the locked amount to the sender as a reward
        giveTransferReward(msg.sender, transferred);
        return true;
    }

    function bulkTransferFixedAmount(address[] calldata tokenOwners, uint256 tokens) public returns (bool success) {
        require(tokenOwners.length > 0);
        uint256 transferred = 0;
        for (uint i = 0; i < tokenOwners.length; i++) {
            if (tokenOwners[i] == address(0x01)) {
                burn(tokens);
                continue;
            }
            transferred += tokens;
            balances[msg.sender] = sub(balances[msg.sender], tokens);
            balances[tokenOwners[i]] = add(balances[tokenOwners[i]], tokens);
            emit Transfer(msg.sender, tokenOwners[i], tokens);
        }

        // For each transfer, we give 0.0005% of the locked amount to the sender as a reward
        giveTransferReward(msg.sender, transferred);
        
        return true;
    }

    function approve(address spender, uint256 tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
        balances[from] = sub(balances[from], tokens);
        allowed[from][msg.sender] = sub(allowed[from][msg.sender], tokens);
        balances[to] = add(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }

    function claim() public returns (bool success) {
        return claimFor(msg.sender);
    }

    function claimFor(address to) public returns (bool success) {
        // Require that the null address has enough balance to claim
        require(balances[address(0x0)] >= (1 << _epoch));

        // Give the sender the reward
        balances[to] = add(balances[to], (1 << _epoch));
        balances[address(0x0)] = sub(balances[address(0x0)], (1 << _epoch));

        // Announce the transfer
        emit Transfer(address(0x0), to, (1 << _epoch));
        
        // Increment the round
        _round = add(_round, 1);

        // If the round is 8, halve the rewards
        if (_round >= 8) {
            _round = 0;
            _epoch = sub(_epoch, 1);
        }
        return true;
    }

    function currentReward() public view returns (uint256 reward) {
        return (1 << _epoch);
    }

    function burn(uint256 tokens) public returns (bool success) {
        balances[msg.sender] = sub(balances[msg.sender], tokens);

        // Burnt tokens are transferred to 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF
        balances[address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)] = add(balances[address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)], tokens);

        _totalBurned = add(_totalBurned, tokens);

        emit Transfer(msg.sender, address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF), tokens);

        return true;
    }

    function totalBurned() public view returns (uint256 total) {
        return _totalBurned;
    }

    function totalLocked() public view returns (uint256 total) {
        return balances[address(0x01)];
    }

    function lottery(uint256 amount) public returns (bool win) {
        // Check for sufficient balance
        require(balances[msg.sender] >= amount && amount > 0 && (amount / 2000 * 198) <= balances[address(0x01)]);

        // Get previous block hash
        bytes32 blockHash = blockhash(block.number - 1);

        // Get the MSB of amount
        uint256 msb = amount;
        while (msb >= 10) {
            msb = msb / 10;
        }
        require(msb >= 1 && msb <= 9);

        balances[msg.sender] = sub(balances[msg.sender], amount);
        balances[address(0x01)] = add(balances[address(0x01)], amount);
        _totalLocked = add(_totalLocked, amount);
        emit Transfer(msg.sender, address(0x01), amount);

        uint256 winningNumber = uint8(blockHash[31]);
        if ((msb % 2) == (winningNumber % 2)) {
            uint256 winAmount = (amount / 100) * 198;
            balances[msg.sender] = add(balances[msg.sender], winAmount);
            balances[address(0x01)] = sub(balances[address(0x01)], winAmount);
            _totalLocked = sub(_totalLocked, winAmount);
            emit Transfer(address(0x01), msg.sender, winAmount);
            win = true;
        }
    }
}