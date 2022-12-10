/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: GPL-3.0



pragma solidity ^0.8.0;

contract luckydraw{
    
    address owner;
    
    struct lottery_draw{
        uint256 price;
        uint256 time_start;
        uint256 time_end;
        address[] participants;
        uint256 total_amount;
        uint256 owner_share;
    }
    
    lottery_draw Daily; 
    lottery_draw Weekly; 
    lottery_draw Monthly; 
    
    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner {
      require(msg.sender == owner, 'Sorry ! You are no Owner.');
      _;
    }
    
    function set_period_daily() public onlyOwner {
        Daily.time_start = block.timestamp;
        Daily.time_end = Daily.time_start + (1 days);
    }
    function set_price_share_daily(uint256 _price, uint256 _share) public onlyOwner{
        Daily.price = _price;
        Daily.owner_share = _share;
    }

    function set_period_weekly() public onlyOwner{
        Weekly.time_start = block.timestamp;
        Weekly.time_end = Weekly.time_start + (7 days);
    }
    function set_price_share_weekly(uint256 _price, uint256 _share) public onlyOwner{
        Weekly.price = _price;
        Weekly.owner_share = _share;
    }

    function set_period_monthly() public onlyOwner{
        Monthly.time_start = block.timestamp;
        Monthly.time_end = Monthly.time_start + (30 days);
    }
    function set_price_share_monthly(uint256 _price, uint256 _share) public onlyOwner{
        Monthly.price = _price;
        Monthly.owner_share = _share;
    }
    
    function participate_daily() public payable returns(bool){
        require(msg.value == Daily.price, 'Amount is not the participating price');
        require(Daily.time_start < block.timestamp , 'Invalid time lower limit');
        require(block.timestamp < Daily.time_end , 'Invalid time upper limit');
        Daily.participants.push(msg.sender);
        Daily.total_amount += msg.value;
        return true;
    }
    
    function participate_weekly() public payable returns(bool){
        require(msg.value == Weekly.price, 'Amount is not the participating price');
        require(Weekly.time_start < block.timestamp, 'Invalid time lower limit');
        require(block.timestamp < Weekly.time_end, 'Invalid time upper limit');
        Weekly.participants.push(msg.sender);
        Weekly.total_amount += msg.value;
        return true;
    }
    
    function participate_monthly() public payable returns(bool){
        require(msg.value == Monthly.price, 'Amount is less than draw participating price');
        require(Monthly.time_start < block.timestamp , 'Invalid time lower limit');
        require(block.timestamp < Monthly.time_end , 'Invalid time upper limit');
        Monthly.participants.push(msg.sender);
        Monthly.total_amount += msg.value;
        return true;
    }
    
    function generate_random(uint256 _randomness, uint256 range) private view returns(uint256){
        uint256 Token = uint256(keccak256(abi.encodePacked(_randomness, msg.sender, block.timestamp)))%range;
        return Token;
    }
    
    function draw_daily(uint256 _randomness) public payable onlyOwner returns(address){
        require(Daily.time_end < block.timestamp, 'Draw period not over');
        uint256 index = generate_random(_randomness, (Daily.participants.length));
        uint256 prize = Daily.total_amount - ((Daily.total_amount * Daily.owner_share)/100);
        address lucky_winner = Daily.participants[index];
        Daily.total_amount = 0;
        delete Daily.participants;
        payable(lucky_winner).transfer(prize);
        return lucky_winner;
    }
    
    function draw_weekly(uint256 _randomness) public payable onlyOwner returns(address){
        require(Weekly.time_end < block.timestamp, 'Draw period not over');
        uint256 index = generate_random(_randomness, (Weekly.participants.length));
        uint256 prize = Weekly.total_amount - ((Weekly.total_amount * Weekly.owner_share)/100);
        address lucky_winner = Weekly.participants[index];
        Weekly.total_amount = 0;
        delete Weekly.participants; 
        payable(lucky_winner).transfer(prize);
        return lucky_winner;    
    }
    
    function draw_monthly(uint256 _randomness) public payable onlyOwner returns(address){
        require(Monthly.time_end < block.timestamp, 'Draw period not over');
        uint256 index = generate_random(_randomness, (Monthly.participants.length));
        uint256 prize = Monthly.total_amount - ((Monthly.total_amount * Monthly.owner_share)/100);
        address lucky_winner = Monthly.participants[index];
        Monthly.total_amount = 0;
        delete Monthly.participants;
        payable(lucky_winner).transfer(prize);
        return lucky_winner;      
    }
    
    function get_period_daily() public view returns(uint256, uint256){
        return (Daily.time_start, Daily.time_end);
    }
    function get_period_weekly() public view returns(uint256, uint256){
        return (Weekly.time_start, Weekly.time_end);
    }
    function get_period_monthly() public view returns(uint256, uint256){
        return (Monthly.time_start, Monthly.time_end);
    }
    
    function get_daily_participants() public view returns(address[] memory){
        return Daily.participants;
    }
    function get_weekly_participants() public view returns(address[] memory){
        return Weekly.participants;
    }
    function get_monthly_participants() public view returns(address[] memory){
        return Monthly.participants;
    }
    
    function withdraw_amount(uint256 _amount, address _to_address) payable public onlyOwner{
        payable(_to_address).transfer(_amount);
    }
    
}