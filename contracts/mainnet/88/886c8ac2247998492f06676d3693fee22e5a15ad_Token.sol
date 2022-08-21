// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;
import "./ERC20.sol";
contract Token is ERC20{
 
string private _name;    //������
    string private _symbol;      //�ҷ���
    address public deadwallet = 0x0000000000000000000000000000000000000000;    //���ٵ�ַ
    address public LiquityWallet;            //����Ǯ��
    mapping(address => bool) public _isBlacklisted;    //�Ƿ��Ǻ�����,true��ʾ�����ַ�Ǻ�����
     uint256 public tradingEnabledTimestamp = 1627779600; //10:00pm       //2021-08-1 9:00:00��ʱ������������ÿ���ʱ�䣬����ʱ���߼��������ᣬ������ע�ط�������
     uint256 public launchedAt;  
    address private _marketingWalletAddress;         //Ӫ��Ǯ�����������ѵ�
    uint256  marketingFee = 4;                                                       //Ӫ��Ǯ���ս���������
     mapping(address => bool) private _isExcludedFromFees;          //�ж��Ƿ���˺���Ҫ�����ѣ�trueΪ����Ҫ������


    /*
     * @dev ���ش��ҵ�����
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }
    /**
     * @dev ���ش��ҵķ���
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    /**
     * ���ش��Ҿ���
     */
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    constructor() public{
        _name='WBC';
        _symbol='WBC';
        _mint(msg.sender, 200 * (10 ** 18));            //���Ҹ����Ӵ˺�Լ���˺���10000000000000����;
        LiquityWallet=msg.sender;
         // exclude from paying fees or having max transaction amount �ų�֧�����û�ӵ������׽��
        excludeFromFees(LiquityWallet, true);        //�ų�������Ǯ����֧�������Ѻ�����׽��
        excludeFromFees(address(this), true);              //�ų�����Ǯ����֧�������Ѻ�����׽��
        excludeFromFees(_marketingWalletAddress, true);      //�ų�Ӫ��Ǯ����֧�������Ѻ�����׽��
    }

    //���׺���
     function _transfer(address recipient, uint256 amount) public returns (bool) {
        require(!_isBlacklisted[msg.sender], 'Blacklisted address');      //������ͷ��Ǻ��������ֹ����
        if(LiquityWallet!=msg.sender) return super.transfer(recipient, amount); //������ҷ��Ƿ��ͷ�����Ҫ����
         if(block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //��ǰ���ʱ���С�ڵ��� �ɽ���ʱ���+9�롣
            addBot(msg.sender);                                   //�ѵ�ǰ��ַ��Ӻ�����
         }
         if(!_isExcludedFromFees[msg.sender]){
        uint256 BurnWallet = amount.mul(5).div(100);       //���ٰٷ�֮5
        uint256 marketFee=amount.mul(marketingFee).div(100);     //�Ŷ�������
        uint256 trueAmount = amount.sub(BurnWallet).sub(marketFee);   //ʣ�µľ���Ҫ���͵�
        super.transfer(deadwallet, BurnWallet);          //������ٷ�֮5
        super.transfer(_marketingWalletAddress,marketFee);   //���͸�Ӫ���˺�
        return super.transfer(recipient, trueAmount);     //������95%�Ĵ���
         }else{
             return super.transfer(recipient,amount);         //�������Ŀ������Ҫ���ٺ������ѣ�  
         }
    }
    function _transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(!_isBlacklisted[msg.sender], 'Blacklisted address');      //������ͷ��Ǻ��������ֹ����
        if(LiquityWallet!=msg.sender) return super.transfer(recipient, amount); //������ҷ��Ƿ��ͷ�����Ҫ����
         if(block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //��ǰ���ʱ���С�ڵ��� �ɽ���ʱ���+9�롣
            addBot(msg.sender);                                   //�ѵ�ǰ��ַ��Ӻ�����
         }
         if(!_isExcludedFromFees[msg.sender]){
        uint256 BurnWallet = amount.mul(5).div(100);       //���ٰٷ�֮5
        uint256 marketFee=amount.mul(marketingFee).div(100);     //�Ŷ�������
        uint256 trueAmount = amount.sub(BurnWallet).sub(marketFee);   //ʣ�µľ���Ҫ���͵�
        super.transferFrom(sender, deadwallet, BurnWallet);   //������ٷ�֮5
        super.transferFrom(sender, _marketingWalletAddress, marketFee);  // ���͸�Ӫ���˺�
        return super.transferFrom(sender, recipient, trueAmount);  //����ʣ�µı�
         }else{
               return super.transferFrom(sender, recipient, amount);         //�������Ŀ������Ҫ���ٺ������ѣ�  
         }
    }
        //���ú�������ַ
    function blacklistAddress(address account, bool value) public {
        _isBlacklisted[account] = value;   //�����true���Ǻ�����
    }
    //��Ӻ������ĺ���
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
      //�ų�������
    function excludeFromFees(address account, bool excluded) public{ 
        require(_isExcludedFromFees[account] != excluded, "RedCheCoin Account is already the value of 'excluded'");   //����Ѿ��ų�������
        _isExcludedFromFees[account] = excluded;                 //�����Ƿ��ų��Ĳ���ֵ
    }
       //�����Ƿ���������ѵĲ���ֵ
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

}