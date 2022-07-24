/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

pragma solidity 0.8.7;
// SPDX-License-Identifier: MIT

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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


interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}





contract Question{
    ERC20 public platformToken;
    address public contractAddress;
    address private questionCreator;
    string public platformCurrency;
    string public name;
    bool public clickClose = false;
    uint256 private sumVotes = 0;
    uint256 private sumBets = 0; 
    uint256 private totalBetAmount = 0;

    struct ChoiceData{
        string name;
        uint256 vote;
        uint256 betAmounts;
        address[] bettor;
    }

    struct UserData{
        uint256 userReward;
        bool isBet;
        bool isVote;
        uint256 betAmount;
        string choiceBet;
        string choiceVote;
    }

    struct TimestampData {
        uint256 createQuestionAt;
        uint256 startBetAt;
        uint256 startVoteAt;
        uint256 endBetAt;
        uint256 endVoteAt;
    }

    enum questionMode{BET, VOTE}

    mapping(string => ChoiceData) private choiceDataMapping;
    mapping(address => UserData) private userDataMapping;
    string[] private choices;
    string[] private winners;
    TimestampData public timestampData;

    // duration in seconds. 
    constructor(string memory _name,string[] memory _choices, uint256 _startBetAt,uint256 _betDuration,uint256 _startVoteAt,uint256 _voteDuration){    
        timestampData = TimestampData(block.timestamp,block.timestamp + _startBetAt,block.timestamp + _startVoteAt,block.timestamp + _startBetAt+ _betDuration + _betDuration,block.timestamp + _startVoteAt +_voteDuration);
        platformToken = ERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);
        platformCurrency = platformToken.symbol();
        contractAddress = address(this);
        name = _name;
        questionCreator = msg.sender;
        choices = _choices;

        for (uint8 _idx = 0; _idx < _choices.length ; _idx++) { 
            choiceDataMapping[_choices[_idx]].name = _choices[_idx];
      }  
      
    }

    function getContractAddress() public view returns(address){
        return contractAddress;
    }

    function _compareString(string memory a, string memory b) private pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function _checkVotedEnd() private view returns(bool){
        if (block.timestamp >= timestampData.startVoteAt){
             return timestampData.endVoteAt < block.timestamp; 
        }
        return false;
    }

    function _checkBetEnd() private view returns(bool){
        if (block.timestamp >= timestampData.startBetAt){
             return timestampData.endVoteAt < block.timestamp; 
        }
        return false;
    }

    function _checkVoteStart() private view returns(bool){
        return block.timestamp >= timestampData.startVoteAt;
    }
    
    function _checkBetStart() private view returns(bool){
        return block.timestamp >= timestampData.startBetAt;
    }
    
    function _findChoice(string memory choiceName) private view returns(bool) {
        ChoiceData memory _data = choiceDataMapping[choiceName];
        return _compareString(_data.name,choiceName);
    }

    function getVote(string memory choiceName) public view returns(uint256){
        require(_findChoice(choiceName),"not found choice in database");
        return choiceDataMapping[choiceName].vote;
    }

    function getBet(string memory choiceName) public view returns(uint256) {
         require(_findChoice(choiceName),"not found choice in database");
        return choiceDataMapping[choiceName].bettor.length;
    }

    function getQuestionData() public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256){
        return (sumVotes,sumBets,totalBetAmount,timestampData.startBetAt,timestampData.endBetAt,timestampData.startVoteAt,timestampData.endVoteAt);
    }

    function getAllChoices() public view returns(string[] memory,uint256){
        return (choices,choices.length);
    }

    function getChoiceName(uint256 _index) public view returns(string memory) {
        require(_index < choices.length,"index of out range!");
        return choices[_index];
    }

    function getChoiceVoteData(string memory choiceName) public view returns(uint256){
        require(_findChoice(choiceName),"not found choice in database");
        return choiceDataMapping[choiceName].vote;
    }

    function getChoiceBetData(string memory choiceName) public view returns(uint256,uint256){
        require(_findChoice(choiceName),"not found choice in database");
        require(timestampData.endVoteAt < block.timestamp,"You can access choice bet data after ending voting period.");
        return (choiceDataMapping[choiceName].bettor.length,choiceDataMapping[choiceName].betAmounts);
    }

    function getRewardPending() public view returns(uint256){
        return userDataMapping[msg.sender].userReward;
    }

    function vote(string memory choiceName) public {
        require(block.timestamp >= timestampData.startVoteAt && block.timestamp <= timestampData.endVoteAt,"There isn't in voting period.");
        require(!userDataMapping[msg.sender].isBet && !userDataMapping[msg.sender].isVote ,"You already bet or vote therefore you can't vote again.");
        require(_findChoice(choiceName),"This choice isn't exist!");
        userDataMapping[msg.sender] = UserData(0,false,true,0,"",choiceName);
        choiceDataMapping[choiceName].vote++;
        sumVotes++;
    }

    function bet(string memory choiceName,uint256 amount) public {
        require(block.timestamp >= timestampData.startBetAt && block.timestamp <= timestampData.endBetAt,"There isn't in betting period.");
        require(_findChoice(choiceName),"This choice isn't exist!");
        require(platformToken.balanceOf(msg.sender) >= 1e19,"You must own at least 10 Btr first to start betting");
        require(!userDataMapping[msg.sender].isBet && !userDataMapping[msg.sender].isVote ,"You already bet or vote therefore you can't bet again.");
        require(platformToken.balanceOf(msg.sender) >= amount,"Insufficent balance.");

        platformToken.transferFrom(msg.sender,contractAddress,amount);

        userDataMapping[msg.sender] = UserData(0,true,false,amount,choiceName,"");
        choiceDataMapping[choiceName].betAmounts = choiceDataMapping[choiceName].betAmounts + amount;
        choiceDataMapping[choiceName].bettor.push(msg.sender);

        sumBets++;
        totalBetAmount += amount;
    }

    function forceCloseQuestion(questionMode mode) public {
        require(msg.sender == questionCreator,"You can't close voting or bidding without permission.");
        if (mode == questionMode.BET){
            require(block.timestamp >= timestampData.startBetAt && block.timestamp <= timestampData.endBetAt,"The question isn't in betting time");
            timestampData.endBetAt = block.timestamp;
        }
        else{
            require(block.timestamp >= timestampData.startVoteAt && block.timestamp <= timestampData.endVoteAt,"The question isn't in voting time");
            timestampData.endVoteAt = block.timestamp;
        }
    }

    function _getWinner() private view returns(bool[16] memory,uint256 ){
        require(timestampData.endVoteAt < block.timestamp,"The question doesn't close.");
        uint256 maxVote = 0;
        bool[16] memory winner;
        for (uint i = 0; i < choices.length;i++){
            uint choiceVote = choiceDataMapping[choices[i]].vote;
            if (choiceVote > maxVote){
                maxVote = choiceVote;
                for (uint j = 0;j<choices.length;j++){
                    if (j == i){
                        winner[j] = false;
                    }
                    else{
                       winner[j] = true;
                    }   
                }
            }
            else if (choiceVote == maxVote){
                winner[i] = true;
            }
        }
        return (winner,maxVote);
    }

    function closeQuestion() public {
        require(msg.sender == questionCreator,"You don't have a permission to close a question.");
        require(block.timestamp > timestampData.endVoteAt && block.timestamp > timestampData.endBetAt, "The question doesn't finalize you can't close");
        require(clickClose == false,"You already close Question");

        bool[16] memory winner;
        uint256 maxVote;

        (winner,maxVote) = _getWinner();

        uint256 calculateSumWinner = 0;

        for (uint256 _idx = 0; _idx < choices.length;_idx++){
            if (winner[_idx]){
                calculateSumWinner += choiceDataMapping[choices[_idx]].betAmounts;
            }
        }

        //uint256 calculateSumLoser = totalBetAmount - calculateSumWinner; 
        uint256 totalWinnerReward = 95 * totalBetAmount / 100; 

        for (uint256 _idx = 0; _idx < choices.length;_idx++){
            if (winner[_idx]){
                address[] memory _bettors = choiceDataMapping[choices[_idx]].bettor;
                for (uint i = 0;i<_bettors.length;i++){
                    uint256 eachReward = totalWinnerReward * userDataMapping[_bettors[i]].betAmount / calculateSumWinner;
                    userDataMapping[_bettors[i]].userReward = eachReward; // add reward to every winner users.
                }
            }
        }

        clickClose = true;

    } 

    function harvestReward() public {
        platformToken.transfer(msg.sender,userDataMapping[msg.sender].userReward);
    } 

    function getUserInformation() public view returns(uint256,bool,bool,uint256,string memory,string memory){
        UserData memory _userData = userDataMapping[msg.sender];
        return (_userData.userReward,_userData.isBet,_userData.isVote,_userData.betAmount,_userData.choiceBet,_userData.choiceVote);
    }
}





contract QuestionFactory{
    address[] public questionAddress ;

    function createQuestion(string memory _questionName, string[] memory _choices, uint256 _startBetAt, uint256 _betDuration, uint256 _startVoteAt, uint256 _voteDuration ) public {
        Question newQuestion = new Question(_questionName,_choices,_startBetAt,_betDuration,_startVoteAt,_voteDuration);
        address qAddress = newQuestion.getContractAddress();
        questionAddress.push(qAddress);
    }

    function getQuestionAddress() public view returns(address[] memory){
        return questionAddress;
    }
}