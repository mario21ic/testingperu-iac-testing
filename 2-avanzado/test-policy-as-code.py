from tf2 import Tf2, Terraform, TerraformPlanLoader

tf2 = Tf2(Terraform(TerraformPlanLoader()))

@tf2.test("resources.aws_lb.my_alb")
def test_my_alb_tags(self):
    assert self.values.tags.Tool == "Terraform"

tf2.run()
