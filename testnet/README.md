### List of Tests to Perform After Deploying the Cronos Cub Token Contract to the Testnet

1. **Deployment Verification**:
   - Ensure the contract is deployed correctly.
   - Verify the initial supply of tokens is minted to the deployer's address.
   - Verify the fee collector address is set correctly.

2. **Basic Transfer Tests**:
   - Transfer tokens from the deployer to another address.
   - Verify the recipient's balance increases correctly.
   - Verify the sender's balance decreases correctly.

3. **Transfer with Fee Tests**:
   - Execute `transferWithFee` and verify that the correct fee is deducted.
   - Ensure the fee is transferred to the fee collector address.
   - Verify the recipient's balance is correct after the fee deduction.

4. **Allowance and Transfer From Tests**:
   - Approve an allowance for a spender.
   - Execute `transferFromWithFee` and verify that the fee is deducted correctly.
   - Ensure the spender's allowance decreases correctly.
   - Verify the recipient's balance and the fee collector's balance.

5. **Minting Restriction Test**:
   - Attempt to mint new tokens after the initial deployment and ensure it fails.

6. **Burn Functionality Tests**:
   - Burn tokens from the deployer's address.
   - Verify the total supply decreases correctly.
   - Execute `burnFrom` and verify the tokens are burned from the specified address, provided there is an allowance set.

7. **Ownership Tests**:
   - Verify the current owner of the contract.
   - Transfer ownership to a new address.
   - Verify the new owner address.
   - Attempt to perform owner-only actions from the previous owner address and ensure it fails.
   - Verify owner-only actions work from the new owner address.

8. **Fee Management Tests**:
   - Set a new fee percentage using `setFeePercent` and verify it updates correctly.
   - Set a new fee collector address using `setFeeCollector` and verify it updates correctly.

9. **Edge Case Tests**:
   - Attempt to transfer tokens to the zero address and ensure it fails.
   - Attempt to set the fee collector address to the zero address and ensure it fails.
   - Attempt to set an excessively high fee percentage and ensure it updates correctly.
   - Attempt transfers with amounts that result in very small or zero fees to check for rounding issues.

### Detailed Testing Steps:

1. **Deployment Verification**:
   ```javascript
   // Ensure initial supply is minted to deployer
   assert.equal(await token.balanceOf(deployerAddress), INITIAL_SUPPLY);
   
   // Ensure fee collector address is set
   assert.equal(await token.feeCollector(), feeCollectorAddress);
   ```

2. **Basic Transfer Tests**:
   ```javascript
   // Transfer tokens and verify balances
   await token.transfer(recipientAddress, transferAmount, { from: deployerAddress });
   assert.equal(await token.balanceOf(recipientAddress), transferAmount);
   assert.equal(await token.balanceOf(deployerAddress), INITIAL_SUPPLY - transferAmount);
   ```

3. **Transfer with Fee Tests**:
   ```javascript
   // Transfer tokens with fee and verify balances
   await token.transferWithFee(recipientAddress, transferAmount, { from: senderAddress });
   let fee = (transferAmount * feePercent) / 100;
   let amountAfterFee = transferAmount - fee;
   assert.equal(await token.balanceOf(recipientAddress), amountAfterFee);
   assert.equal(await token.balanceOf(feeCollectorAddress), fee);
   ```

4. **Allowance and Transfer From Tests**:
   ```javascript
   // Approve allowance and transfer from with fee
   await token.approve(spenderAddress, allowanceAmount, { from: ownerAddress });
   await token.transferFromWithFee(ownerAddress, recipientAddress, transferAmount, { from: spenderAddress });
   assert.equal(await token.allowance(ownerAddress, spenderAddress), allowanceAmount - transferAmount);
   ```

5. **Minting Restriction Test**:
   ```javascript
   // Attempt to mint after initial deployment
   try {
       await token.mint(recipientAddress, mintAmount, { from: ownerAddress });
   } catch (error) {
       assert(error.message.includes("Minting can only occur during initial deployment"));
   }
   ```

6. **Burn Functionality Tests**:
   ```javascript
   // Burn tokens and verify total supply
   await token.burn(burnAmount, { from: ownerAddress });
   assert.equal(await token.totalSupply(), INITIAL_SUPPLY - burnAmount);
   ```

7. **Ownership Tests**:
   ```javascript
   // Transfer ownership and verify
   await token.transferOwnership(newOwnerAddress, { from: ownerAddress });
   assert.equal(await token.owner(), newOwnerAddress);
   
   // Ensure only new owner can perform owner-only actions
   try {
       await token.setFeePercent(5, { from: ownerAddress });
   } catch (error) {
       assert(error.message.includes("Caller is not the owner"));
   }
   await token.setFeePercent(5, { from: newOwnerAddress });
   ```

8. **Fee Management Tests**:
   ```javascript
   // Set new fee percent and verify
   await token.setFeePercent(newFeePercent, { from: ownerAddress });
   assert.equal(await token.feePercent(), newFeePercent);
   
   // Set new fee collector and verify
   await token.setFeeCollector(newFeeCollectorAddress, { from: ownerAddress });
   assert.equal(await token.feeCollector(), newFeeCollectorAddress);
   ```

9. **Edge Case Tests**:
   ```javascript
   // Attempt transfer to zero address
   try {
       await token.transfer("0x0000000000000000000000000000000000000000", transferAmount, { from: senderAddress });
   } catch (error) {
       assert(error.message.includes("transfer to the zero address"));
   }
   
   // Attempt to set fee collector to zero address
   try {
       await token.setFeeCollector("0x0000000000000000000000000000000000000000", { from: ownerAddress });
   } catch (error) {
       assert(error.message.includes("New owner is the zero address"));
   }
   ```

By performing these tests, you can ensure that the Cronos Cub Token contract works as expected and is secure before deploying it to the mainnet.
