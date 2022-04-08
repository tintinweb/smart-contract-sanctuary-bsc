// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract TimelockV2 {
    
    struct Locker {
        uint end;
        uint256 duration;
        uint256 amount;
        address token;
    }

    mapping(address => Locker[]) lockers;


    //Function that allow the user to create differents lockers with differents specificity
    function CreateLocker(uint256 _duration,address _token, uint256 _amount) external {
        require(_amount > 0 , "La somme doit etre superieure a 0");
        require(_duration > 0,"La duree doit etre superieure a 0");

        lockers[msg.sender].push(Locker(block.timestamp + _duration, _duration, _amount, _token));
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        
    }

    //Return all the information about a locker (based on his index)
    function GetLocker(address owner, uint256 _index) external view returns (uint256,uint256,uint256,address) {
        require(_index < lockers[owner].length, "Locker inexistant");
        return (lockers[owner][_index].end, lockers[owner][_index].duration, lockers[owner][_index].amount, lockers[owner][_index].token);
    }

    receive() external payable {}

    //Get the number of locker of an address
    function GetLockerCount(address owner) external view returns (uint256) {
        return lockers[owner].length;
    }


    function withdrawByInfos(address payable owner, address token, uint amount) public {
        require(lockers[owner].length > 0, 'Aucun locker n est disponible');
        Locker[] memory lockerscp = lockers[owner];
        bool found = false;
        for(uint i = 0; i < lockers[owner].length; i++) {
            if (lockerscp[i].token == token && 
                lockerscp[i].amount == amount ) {
                    found = true;
                    this.CashOut(owner, i);
            }
        }
        require(found, 'Aucun locker trouve');

    }

    function CashOut(address payable owner, uint index) public {
        require(block.timestamp >= lockers[owner][index].end, 'too early');
        if (lockers[owner][index].token == address(0)) {
            owner.transfer(lockers[owner][index].amount);
        } else {
            IERC20(lockers[owner][index].token).transfer(owner, lockers[owner][index].amount);
        }
        if(lockers[owner].length == 1) {
            lockers[owner].pop();
        } else {
            lockers[owner][index] = lockers[owner][lockers[owner].length - 1];
            lockers[owner].pop();
        }
    }


}