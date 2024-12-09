/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/


output "security_group_id" {
  value = aws_security_group.main.id
}