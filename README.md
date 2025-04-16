# Terraform Module Creation Best Practices

## 1. Modular Design
   - **Create Smaller, Opinionated Modules**: Build smaller modules that are focused on specific functionality rather than one large, complex module. This minimizes duplication and keeps the module design clean and easy to maintain.
   - **Avoid Overcomplication**: Limit the scope of each module. Avoid adding unnecessary features that might make the module harder to use and understand. Simplicity is key.

## 2. Consistency in Variable Naming
   - **Match Upstream Variable Names**: Ensure that the names of input variables in your module align with those used in the upstream systems or modules. This consistency reduces confusion for users and helps maintain clarity in your module's behavior.

## 3. Descriptive Variables and Comments
   - **Use Descriptions for Inputs**: Always provide clear descriptions for input variables. This helps users understand the purpose of each variable, improving usability.
   - **Add Extra Comments**: Where applicable, include additional comments in the code to clarify complex logic or decisions made during the module’s development.

## 4. Use Sane Defaults
   - **Set Secure and Practical Defaults**: Default values should follow best practices and ensure the most secure and functional configuration. For example, use defaults that comply with security guidelines (e.g., encryption enabled by default for storage services).

## 5. Mandatory Tagging Standards
   - **Common Tagging Convention**: Ensure every resource in the module includes common tags such as `global/label`. This practice ensures uniformity across your infrastructure and facilitates management and reporting.

## 6. Leverage Existing, Widely-Used Modules
   - **Reuse Well-Maintained Modules**: Before creating a custom module, check for existing, trusted modules that fulfill the same purpose. For example, use modules from:
     - [terraform-aws-modules](https://github.com/terraform-aws-modules)
     - [cloudposse](https://docs.cloudposse.com/modules/library/aws/)

   Reusing well-established modules can save time, ensure best practices, and reduce the risk of introducing errors.

## 7. Version Pinning
   - **Pin Module Versions Explicitly**: Always specify exact versions or version constraints for modules to avoid breaking changes. Using wide version ranges such as `>= 19.16, < 20.0` is not recommended because it can lead to unpredictable behavior due to updates. Stick to exact version pinning to maintain stability and predictability in your infrastructure.
