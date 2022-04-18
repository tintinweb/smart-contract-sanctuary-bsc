/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

pragma solidity 0.8.0;
//"SPDX-License-Identifier:UNLICENSED"

interface TTracker{
    function getTBalance(address _sender)  external view  returns(uint256);
    function getSBalance(address _sender)  external view  returns(uint256);
    function getPreAddr(address _sender)  external view  returns(address);
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Tracker is TTracker{

        using SafeMath for uint256;
        //0x15002D330deD77Ad4577662Fb19584bD6907F20f 0xa1656d8B3578E85Fd5F104431F06B2f3A82EfD2b
        address public _trwAddress = 0x15002D330deD77Ad4577662Fb19584bD6907F20f;
        //0x22d1dcB6A65644f5A9BE1bEa025fB99a9C5A38C3 0xa5F90A7320742098313C28DDbe790113dAE616e5
        address public _scmAddress = 0x22d1dcB6A65644f5A9BE1bEa025fB99a9C5A38C3;

        address public receAddress = 0x78BB3A2a160f48de98cF45490925b880EBB4AD9F;

        address public account = 0xC88312d7cdC2b15e557D4F79c73D31a55E2ed4E1;

        address public adminAccount = 0xC88312d7cdC2b15e557D4F79c73D31a55E2ed4E1;

        IBEP20 public _trwToken;

        IBEP20 public _scmToken;

        uint256 private _fee = 0.003 *10**18;

        uint256 private _trwAmount = 30000000 *10**18;

        uint256 private _scmAmount = 30000000 *10**18;

        mapping(address => uint256) public _trwBalance;

        mapping(address => uint256) public _scmBalance;

        mapping(address => uint8) public _typeMap;

        address[] public _airDropAddress;

        uint256 public _totalTrwAmount;

        uint256 public _totalScmAmount;

        struct UserInfo{
            address sender;
            address preAddress;
            uint256 addTime;
        }

        mapping(address => UserInfo) public _userMap;

        event transferBnb(address _from, uint256 value);


        constructor () {
            _trwToken = IBEP20(_trwAddress);
            _scmToken = IBEP20(_scmAddress);

            _userMap[msg.sender] = UserInfo(msg.sender,address(this), block.timestamp);
            _typeMap[msg.sender] = 1;
        }

        function setFee(uint256 _feeTo) public{
            require(msg.sender == adminAccount, "permission denied");
            _fee = _feeTo;
        }

        function setTrwBalance(uint256 _amount) public{
            require(msg.sender == adminAccount, "permission denied");
            _trwAmount = _amount;
        }

        function setScmBalance(uint256 _amount) public{
            require(msg.sender == adminAccount, "permission denied");
            _scmAmount = _amount;
        }

        function airdrop(address _sender, address _preSender, uint8 _tokenType) payable public{
            require(msg.value == _fee, 'need to consume: 0.03BNB');
            require(_sender != address(0), '_sender: airdrop from the zero address');
            require(_preSender != address(0), '_preSender: airdrop from the zero address');
            require(_userMap[_sender].preAddress ==  address(0), '_sender relationShip: already airdrop');
            require(_userMap[_preSender].preAddress !=  address(0), '_preSender relationShip: not airdrop');
            require(_userMap[_sender].preAddress != _preSender, '_sender: already airdrop');
            require(_tokenType == 1 || _tokenType == 2, '_tokenType error: _tokenType 1 is TRW, _tokenType 2 is SCM');
            _userMap[_sender] = UserInfo(_sender, _preSender, block.timestamp);

            if(_tokenType == 1){
                _trwBalance[_sender] = _trwBalance[_sender].add(_trwAmount);
                _totalTrwAmount += _trwAmount;
            }else{
                _scmBalance[_sender] = _scmBalance[_sender].add(_scmAmount);
                _totalScmAmount += _scmAmount;
            }
            doExecution(_sender, _preSender, _tokenType);
            _typeMap[_sender] = _tokenType;
            _airDropAddress.push(_sender);
            emit transferBnb(_sender, msg.value);
        }

        function doExecution(address _sender, address _preSender, uint8 _tokenType) private{
            if(_tokenType == 1){
                 _trwBalance[_preSender] = _trwBalance[_preSender].add(_trwAmount);
                _totalTrwAmount += _trwAmount;

                 UserInfo memory user = _userMap[_preSender];
                 address preAddress = user.preAddress;
                 if(preAddress != address(0)){
                     user = _userMap[preAddress];
                     if(user.preAddress != address(0)){
                         uint256 secondRe = _trwAmount.mul(30).div(100);
                        _trwBalance[preAddress] = _trwBalance[preAddress].add(secondRe);
                        _totalTrwAmount += secondRe;
                        
                        address ppAddress = user.preAddress;
                        user = _userMap[ppAddress];
                        if(user.preAddress != address(0)){
                            uint256 thirdRe = _trwAmount.mul(10).div(100);
                              _trwBalance[ppAddress] = _trwBalance[ppAddress].add(thirdRe);
                              _totalTrwAmount += thirdRe;
                        }
                     }
                 }
            }else{
                 _scmBalance[_preSender] = _scmBalance[_preSender].add(_scmAmount);
                _totalScmAmount += _scmAmount;

                 UserInfo memory user = _userMap[_preSender];
                 address preAddress = user.preAddress;
                 if(preAddress != address(0)){
                     user = _userMap[preAddress];
                     if(user.preAddress != address(0)){
                         uint256 secondRe = _scmAmount.mul(30).div(100);
                        _scmBalance[preAddress] = _scmBalance[preAddress].add(secondRe);
                        _totalScmAmount += secondRe;
                        
                        address ppAddress = user.preAddress;
                        user = _userMap[ppAddress];
                        if(user.preAddress != address(0)){
                            uint256 thirdRe = _scmAmount.mul(10).div(100);
                              _scmBalance[ppAddress] = _scmBalance[ppAddress].add(thirdRe);
                              _totalScmAmount += thirdRe;
                        }
                     }
                 }
            }
        }

        function getTeam(address _sender) public view returns(uint8, uint8){
            uint8 dirCount = 0;
            uint8 teamCount = 0;
            for(uint256 i = 0; i < _airDropAddress.length; i++){
                address addr = _airDropAddress[i];
                address pre = _userMap[addr].preAddress;
                if(_sender == pre){
                    teamCount ++;
                    dirCount ++;
                    teamCount = calTeamCount(addr, teamCount);
                }
            }
            return (dirCount, teamCount);
        }

        function calTeamCount(address _sender, uint8 teamCount) public view returns(uint8){
            for(uint256 i = 0; i < _airDropAddress.length; i++){
                address addr = _airDropAddress[i];
                address pre = _userMap[addr].preAddress;
                if(_sender == pre){
                    teamCount ++;
                    return calTeamCount(addr, teamCount);
                }
            }
            return teamCount;
        }

        function getDirInfo(address _sender) public view returns(UserInfo[] memory){
            uint8 dirCount = 0;
            for(uint256 i = 0; i < _airDropAddress.length; i++){
                address addr = _airDropAddress[i];
                address pre = _userMap[addr].preAddress;
                if(_sender == pre){
                    dirCount ++;
                }
            }
            UserInfo[] memory userInfos = new UserInfo[](dirCount);
            uint8 tmp = 0;
            for(uint256 i = 0; i < _airDropAddress.length; i++){
                address addr = _airDropAddress[i];
                address pre = _userMap[addr].preAddress;
                if(_sender == pre){
                    userInfos[tmp] = _userMap[addr];
                    tmp ++;
                }
            }
            return userInfos;
        }

        function getTotal(uint8 _tokenType) public view returns(uint256){
            require(_tokenType == 1 || _tokenType == 2, '_tokenType error: _tokenType 1 is TRW, _tokenType 2 is SCM');
            if(_tokenType == 1){
                return _totalTrwAmount;
            }else{      
                return _totalScmAmount;
            }
        }

        function checkType(address _sender) public view returns(uint8){
            return _typeMap[_sender];
        }

        function getTBalance(address _sender) external view  override returns(uint256){
            require(_sender != address(0), '_sender: getTBalance from the zero address');
            return _trwBalance[_sender];
        }

        function getSBalance(address _sender) external view  override returns(uint256){
            require(_sender != address(0), '_sender: getSBalance from the zero address');
            return _scmBalance[_sender];
        }

         function getPreAddr(address _sender)  external view override returns(address){
             require(_sender != address(0), '_sender: getSBalance from the zero address');
            return _userMap[_sender].preAddress;
         }

        function transfer() public  {
            // require(msg.sender == adminAccount, "permission denied");
            payable(account).transfer(address(this).balance);
        }
        function getbalance() public view returns(uint){
            return address(this).balance;
        }

        function getBnbBalance(address sender) public view returns(uint){
            return address(sender).balance;
        }
}