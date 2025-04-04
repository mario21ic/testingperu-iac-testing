from tf2 import Tf2, Terraform, TerraformPlanLoader

tf2 = Tf2(Terraform(TerraformPlanLoader()))


# @tf2.test("modules.ec2_instance")
# def test_ec2_instance(self):
#     assert self.values.tags.Tool == "Terraform"

@tf2.test("resources.aws_security_group.lb_sg")
def test_lb_sg_tags(self):
    assert self.values.tags.Tool == "Terraform"

@tf2.test("resources.aws_lb.my_alb")
def test_my_alb_tags(self):
    assert self.values.tags.Tool == "Terraform"

tf2.run()
