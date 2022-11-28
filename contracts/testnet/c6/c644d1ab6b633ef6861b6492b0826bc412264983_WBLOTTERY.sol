/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

//SPDX-License-Identifier: MIT License
pragma solidity ^0.8.17;

interface Itoken {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 retue);

    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 retue
    );
}

contract WBLOTTERY {
    uint256 public nonce;
    address public Admin;
    address public Marketing_Wallet;
    address public Liquidity_Wallet;
    Itoken public token;
    uint256 public duration;
    uint256 public lottery_price;

    uint256[3] public winners_percentages = [45, 25, 10];

    //distribution criteria
    uint256 public marketing_percentage = 3;
    uint256 public liquidity_percentage = 7;
    uint256 public refferal_percentage = 10;
    uint256 public divider = 100;

    mapping(address => uint256) public refferal_part;

    //address's

    struct lotterydata {
        //address[] participants;
        uint256[] participants;
        address[] uniqueaddress;
        mapping(address => bool) hasparticipated;
        mapping(address => bool) won;
        address[] winners;
        address[] refferals;
        uint256 prize;
        uint256 start_time;
        uint256 end_time;
        uint256 tickets;
        uint256[] winner_reward;
        uint256[] winner_reward_received;
        uint256[] winner_ref_reward_received;
    }

    struct player {
        address player_address;
        uint256 overall_rewards;
        uint256 overall_lotteries_bought;
        mapping(uint256 => uint256) lotteries_bought;
        mapping(uint256 => uint256) lotteries_rewards;
        mapping(uint256 => bool) lotteries_won;
        mapping(uint256 => bool) claimed_rewards;
    }

    struct better {
        address better_address;
        uint256 better_id;
        uint256 better_amount;
    }

    mapping(address => better) public betters;
    address[] pplayers;

    mapping(uint256 => lotterydata) private lotteries;
    mapping(address => player) public players;
    mapping(address => address) public reffral;

    event BOUGHT(address player, uint256 lotteries_bought, uint256 nonce);
    event WON(address player, uint256 claimed_rewards, uint256 nonce);
    event WON2(address winner1, address winner2, address winner3, uint256 prize1, uint256 prize2, uint256 prize3);
    event REFWON(address ref1, address ref2, address ref3, uint256 refprize1, uint256 refprize2, uint256 refprize3);
    event reffralClaim(address referral, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == Admin);
        _;
    }

    constructor() {
        Admin = 0xabc4B357D7419cfD3747DC1338e9e6308612D87c;
        Marketing_Wallet = 0x42A20C445E2442cd54fa6199c0069b182bd0B6e2;
        Liquidity_Wallet = 0xcdE642b47dB090b70dD25f3D7B35A247DEe4b412;
        nonce = 0;
        token = Itoken(0xcdE642b47dB090b70dD25f3D7B35A247DEe4b412); //token
        duration = 7 days;
        lottery_price = 10 * (10**token.decimals());
        lotteries[nonce].start_time = block.timestamp;
        lotteries[nonce].end_time = block.timestamp + duration;
    }

    function distribution() external onlyAdmin {
        
        uint256 pricediscount = lottery_price * 90 / 100;
        uint256 amount = 0;
        uint256 tickets = lotteries[nonce].tickets;
        address[] memory _participants = new address[](tickets);
        uint256 pLenght = pplayers.length;
        uint256 pp = 0;
        for (uint256 i = 0; i < pLenght; i++) {
            amount = betters[pplayers[i]].better_amount / pricediscount;
            for (uint256 p = 0; p < amount; p++) {
                _participants[pp] = pplayers[i];
                pp++;
            }
        }

        address winner1 = getwinners(0, _participants);
        address winner2 = getwinners(1, _participants);
        address winner3 = getwinners(2, _participants);

        uint256 prize1 = lotteries[nonce].prize * winners_percentages[0] / divider;
        uint256 prize2 = lotteries[nonce].prize * winners_percentages[1] / divider;
        uint256 prize3 = lotteries[nonce].prize * winners_percentages[2] / divider;

        uint256 refprize1 = (lotteries[nonce].prize * winners_percentages[0] / divider) * 10 / divider;
        uint256 refprize2 = (lotteries[nonce].prize * winners_percentages[1] / divider) * 10 / divider;
        uint256 refprize3 = (lotteries[nonce].prize * winners_percentages[2] / divider) * 10 / divider;

        address ref1 = reffral[winner1];
        address ref2 = reffral[winner2];
        address ref3 = reffral[winner3];

        if(reffral[winner1] != address(0)){
            prize1 -= refprize1;
            //refferal_part[reffral[winner1]] += refprize1;
        }
        if(reffral[winner2] != address(0)){
            prize2 -= refprize2;
            //refferal_part[reffral[winner2]] += refprize2;
        }
        if(reffral[winner3] != address(0)){
            prize3 -= refprize3;
            //refferal_part[reffral[winner3]] += refprize3;
        }

        //token.transfer(winner1, prize1);
        //token.transfer(winner2, prize2);
        //token.transfer(winner3, prize3);
        emit WON2(winner1, winner2, winner3, prize1, prize2, prize3);
        emit REFWON(ref1, ref2, ref3, refprize1, refprize2, refprize3);
    }

    function getwinners(uint256 index, address[] memory _part) internal view returns (address winner) {
        uint256 winner_index = random(
            _part.length,
            index
        );
        return _part[winner_index];
    }

    function refClaim() public {
        require(refferal_part[msg.sender] > 0 , "Nothing to claim");
        require(token.balanceOf(address(this)) >= refferal_part[msg.sender], "Low amount of tokens");
        uint256 amount = refferal_part[msg.sender];
        token.transfer(msg.sender, amount);
        refferal_part[msg.sender] = 0;

        emit reffralClaim(msg.sender, amount);
    }

    function buy(uint256 count, address ref) public {
        require(block.timestamp < lotteries[nonce].end_time, "time passed");
        //require(msg.sender != ref && ref != address(0), "Invalid ref address");
        require(msg.sender != ref, "Invalid ref address");
        require(count > 0, "Invalid numerber of tickets");
        if(reffral[msg.sender] == address(0)){
            if(ref != address(0)){
                reffral[msg.sender] = ref;
            }
            
        }
        //reffral[msg.sender] = ref;
        token.transferFrom(msg.sender, address(this), count * lottery_price);
        //player storage user = players[msg.sender];
        //user.overall_lotteries_bought += count;
        //user.lotteries_bought[nonce] += count;
        //mudança

        if(betters[msg.sender].better_id == 0){
            pplayers.push(msg.sender);
            betters[msg.sender].better_address = msg.sender;
            betters[msg.sender].better_id = pplayers.length;
        }

        //fim da mudança
        //for (uint256 i = 0; i < count; i++) {
            //lotteries[nonce].participants.push(msg.sender);
        //    lotteries[nonce].participants.push(bid);
        //}

        uint256 amount = count * lottery_price;
        uint256 refamount = (amount * refferal_percentage) / divider;
        //token.transfer(ref, refamount);
        if(reffral[msg.sender] != address(0)){
            refferal_part[ref] += refamount;
        }
        if(reffral[msg.sender] != address(0)){
            lotteries[nonce].prize += amount - refamount;
        }else{
            lotteries[nonce].prize += amount;
        }
        
        betters[msg.sender].better_amount += amount - refamount;
        if (!lotteries[nonce].hasparticipated[msg.sender]) {
            lotteries[nonce].uniqueaddress.push(msg.sender);
            lotteries[nonce].hasparticipated[msg.sender] = true;
        }
        lotteries[nonce].tickets += count;
        emit BOUGHT(msg.sender, count, nonce);
    }

    function setwinners() external onlyAdmin {
        require(block.timestamp > lotteries[nonce].end_time);
        if (lotteries[nonce].participants.length > 0) {
            for (
                uint256 i = 0;
                i < winners_percentages.length &&
                    i < lotteries[nonce].uniqueaddress.length;
                i++
            ) {
                
                address winner = pplayers[getwinner(i) - 1];

                lotteries[nonce].won[winner] = true;
                lotteries[nonce].winners.push(winner);
                lotteries[nonce].refferals.push(reffral[winner]);
                lotteries[nonce].winner_reward.push(
                    (lotteries[nonce].prize * winners_percentages[i]) / 100
                );

                player storage user = players[lotteries[nonce].winners[i]];
                user.overall_rewards += lotteries[nonce].winner_reward[i];
                user.lotteries_rewards[nonce] += lotteries[nonce].winner_reward[
                    i
                ];
                user.lotteries_won[nonce] = true;
                user.claimed_rewards[nonce] = true;

                token.transfer(
                    lotteries[nonce].winners[i],
                    (lotteries[nonce].winner_reward[i] -
                        (lotteries[nonce].winner_reward[i] *
                            refferal_percentage) /
                        divider)
                );

                token.transfer(
                    reffral[lotteries[nonce].winners[i]],
                    (lotteries[nonce].winner_reward[i] * refferal_percentage) /
                        divider
                );

                lotteries[nonce].winner_reward_received.push(
                    (lotteries[nonce].winner_reward[i] -
                        (lotteries[nonce].winner_reward[i] *
                            refferal_percentage) /
                        divider)
                );
                lotteries[nonce].winner_ref_reward_received.push(
                    (lotteries[nonce].winner_reward[i] * refferal_percentage) /
                        divider
                );
                emit WON(
                    lotteries[nonce].winners[i],
                    lotteries[nonce].winner_reward[i],
                    nonce
                );
            }
        }

        if (lotteries[nonce].prize > 0) {
            token.transfer(
                Marketing_Wallet,
                (lotteries[nonce].prize * marketing_percentage) / divider
            );
            token.transfer(
                Liquidity_Wallet,
                (lotteries[nonce].prize * liquidity_percentage) / divider
            );
        }

        nonce++;
        lotteries[nonce].start_time = block.timestamp;
        lotteries[nonce].end_time = block.timestamp + duration;
    }

    //function getwinner(uint256 index) internal view returns (address winner) {
    function getwinner(uint256 index) internal view returns (uint256 winner) {
        uint256 winner_index = random(
            lotteries[nonce].participants.length,
            index
        );
        return lotteries[nonce].participants[winner_index];
    }

    function random(uint256 length, uint256 _index)
        internal
        view
        returns (uint256 index)
    {
        uint256 random_number = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    address(this),
                    block.number,
                    block.coinbase,
                    length,
                    _index
                )
            )
        );
        return random_number % length;
    }

    function get_lottery_data(uint256 index)
        public
        view
        returns (
            address[] memory winner,
            uint256 prize,
            uint256 start_time,
            uint256 end_time,
            uint256[] memory winner_reward,
            uint256[] memory participants
        )
    {
        return (
            lotteries[index].winners,
            lotteries[index].prize,
            lotteries[index].start_time,
            lotteries[index].end_time,
            lotteries[index].winner_reward,
            lotteries[index].participants
        );
    }

    function get_lottery_data_2(uint256 index)
        public
        view
        returns (
            address[] memory reffrals,
            uint256[] memory winner_reward_received,
            uint256[] memory winner_ref_reward_received
        )
    {
        return (
            lotteries[index].refferals,
            lotteries[index].winner_reward_received,
            lotteries[index].winner_ref_reward_received
        );
    }

    function get_user_data(address user, uint256 index)
        public
        view
        returns (
            uint256 lotteries_bought,
            uint256 lotteries_rewards,
            bool lotteries_won,
            bool claimed_rewards
        )
    {
        return (
            players[user].lotteries_bought[index],
            players[user].lotteries_rewards[index],
            players[user].lotteries_won[index],
            players[user].claimed_rewards[index]
        );
    }

    function set_token(Itoken _token) external onlyAdmin {
        require(address(_token) != address(0));
        token = _token;
    }

    function set_lottery_price(uint256 _lottery_price) external onlyAdmin {
        require(_lottery_price > 0);
        lottery_price = _lottery_price;
    }

    function set_admin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0));
        Admin = newAdmin;
    }

    function set_marketing_wallet(address newMarketing_Wallet)
        external
        onlyAdmin
    {
        require(newMarketing_Wallet != address(0));
        Marketing_Wallet = newMarketing_Wallet;
    }

    function set_liquidity_wallet(address newLiquidity_Wallet)
        external
        onlyAdmin
    {
        require(newLiquidity_Wallet != address(0));
        Liquidity_Wallet = newLiquidity_Wallet;
    }

    function get_contract_balance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function withdraw_stuck_token(Itoken _token, uint256 stuck_amount)
        external
        onlyAdmin
    {
        require(address(_token) != address(0));
        require(
            stuck_amount > 0 && stuck_amount <= token.balanceOf(address(this))
        );
        _token.transfer(msg.sender, stuck_amount);
    }

    function set_marketing_percentage(uint256 _marketing_percentage)
        external
        onlyAdmin
    {
        require(_marketing_percentage > 0);
        marketing_percentage = _marketing_percentage;
    }

    function set_liquidity_percentage(uint256 _liquidity_percentage)
        external
        onlyAdmin
    {
        require(_liquidity_percentage > 0);
        liquidity_percentage = _liquidity_percentage;
    }

    function set_refferal_percentage(uint256 _refferal_percentage)
        external
        onlyAdmin
    {
        require(_refferal_percentage > 0);
        refferal_percentage = _refferal_percentage;
    }

    function set_duration(uint256 _duration) external onlyAdmin {
        require(_duration > 0);
        duration = _duration;
    }
}