/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

contract CryptoCarouselReferralProgram{
    uint256 levels;
    mapping(uint256=>uint256) percent;
    
    constructor(){
        levels = 3;
        percent[1] = 5;
        percent[2] = 3;
        percent[3] = 1;
    }

    function getPercent(uint256 _level) public view returns(uint256){
        require(_level > 0 && _level <= levels, "Incorrect level");
        return percent[_level];
    }

    function getLevels() public view returns(uint256){
        return levels;
    }
}